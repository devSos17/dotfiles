#!/usr/bin/env -S python3 -I
"""PreToolUse guard for the Bash tool.

Principle: inspect infrastructure, never its contents. We have access to
customer environments that hold PHI/PII and to our own credentials; neither
may ever land in a transcript, a local file, or a deliverable.

deny -> blocked outright (secrets and customer data reads)
ask  -> Sos must approve that specific call (gray areas)

This is a guardrail against accidents, not a security boundary: an obfuscated
command can get past regexes. The written rules in ~/dev/CLAUDE.md still apply.
"""
import json
import re
import sys

SECRET_VAR = r"\$\{?[A-Za-z0-9_]*(TOKEN|SECRET|PASSWORD|PASSWD|API_KEY|ACCESS_KEY|SESSION_KEY|PRIVATE_KEY|CREDENTIAL)[A-Za-z0-9_]*"

DENY = [
    # Environment dumps: every Bitwarden-loaded token and faws credential lives there.
    (r"(^|[;&|(`]\s*)(env|printenv)(\s*$|\s*[|;&>)`])", "dumps the environment (tokens, AWS creds)"),
    (r"(^|[;&|(`]\s*)printenv\s+\S", "prints an environment variable"),
    (r"(^|[;&|(`]\s*)(set|export\s+-p|declare\s+-[a-zA-Z]*[px])(\s*$|\s*[|;&>)])", "dumps shell variables"),
    (r"\b(echo|printf|print)\b[^|;&]*" + SECRET_VAR, "prints a secret-bearing variable"),
    (r"<<<\s*\"?" + SECRET_VAR, "feeds a secret variable to stdout-capable command"),
    # Credential helpers that print to stdout.
    (r"(?<!\$\()(?<!\$\( )\bfaws\s+env\b", "bare `faws env` prints AWS keys; use eval \"$(faws env -A <alias>)\" && aws sts get-caller-identity"),
    (r"\baws\s+configure\s+(get\s+\S*(secret|token|key)|export-credentials)", "prints AWS credentials"),
    (r"\b(cat|less|more|head|tail|bat|grep|rg|awk|sed|cp|base64)\b[^|;&]*(\.aws/credentials|\.config/secrets|\.ssh/id_|\.gnupg/|\.netrc|key\.txt)", "reads a credential store"),
    (r"\bsecurity\s+find-(generic|internet)-password\b.*\s-[a-z]*w", "prints a keychain secret"),
    (r"\bbw\s+(get|unlock|export|list\s+items)\b", "reads Bitwarden secrets"),
    (r"\bgh\s+auth\s+(token|status\s+.*--show-token)", "prints the GitHub token"),
    (r"\bTF_LOG(_PROVIDER|_CORE)?=(debug|trace|json)", "TF_LOG debug/trace logs SSO roleCredentials bodies"),
    (r"\b(curl|wget)\b.*\s-(v|-verbose|-trace\S*)\b.*(-u|--user|Authorization)", "verbose curl prints auth headers"),
    # AWS data plane: secret values and customer data.
    (r"\baws\s+secretsmanager\s+(get-secret-value|batch-get-secret-value)\b", "reads secret values (describe-secret/list-secrets are fine)"),
    (r"\baws\s+ssm\s+get-parameters?(-by-path)?\b.*--with-decryption", "decrypts SecureString parameters"),
    (r"\baws\s+s3\s+(cp|mv|sync)\s+s3://", "downloads object contents (ls / s3api head-object / get-bucket-* are fine)"),
    (r"\baws\s+s3api\s+(get-object|select-object-content|get-object-torrent)\b", "reads object contents"),
    (r"\baws\s+s3\s+presign\b", "creates a link to object contents"),
    (r"\baws\s+dynamodb\s+(scan|query|get-item|batch-get-item|execute-statement|batch-execute-statement|execute-transaction|transact-get-items)\b", "reads table data (describe-table is fine)"),
    (r"\baws\s+(rds-data\s+execute-statement|athena\s+get-query-results|redshift-data\s+get-statement-result|timestream-query\s+query)\b", "reads database rows"),
    (r"\baws\s+(sqs\s+receive-message|kinesis\s+get-records|kafka\s+\S*get-records)\b", "reads message payloads"),
    (r"\baws\s+cognito-idp\s+(list-users|admin-get-user|list-users-in-group|admin-list-groups-for-user)\b", "reads end-user PII"),
    (r"\baws\s+(ec2\s+get-password-data|lightsail\s+get-instance-access-details)\b", "reads instance passwords"),
    (r"\baws\s+(healthlake|medical-imaging|omics)\s+\S*(get|read|search|export|start)\S*", "reads health data"),
    # Kubernetes secret values.
    (r"\bkubectl\b.*\bget\s+(secret|secrets)\b.*(-o|--output)[ =]?(yaml|json|jsonpath|go-template)", "prints Kubernetes secret values (get secrets without -o is fine)"),
    (r"\bkubectl\b.*\bview-secret\b", "prints Kubernetes secret values"),
]

# A curl/wget/httpie call that targets Atlassian (Confluence or JIRA, ours or a customer's)
# and carries a write method or a body. `curl -G --data-urlencode` is a GET (the /jira skill).
_ATL = r"(atlassian\.net|\$\{?(JIRA_URL|CONFLUENCE_URL|MGHILL_CONFLUENCE_URL|[A-Z_]*CONFLUENCE[A-Z_]*_URL)\b)"
_WRITE = r"(-X\s*|--request[ =]\s*)['\"]?(POST|PUT|PATCH|DELETE)\b|\s(-d|--data(-raw|-binary|-urlencode)?|--json|-F|--form|-T|--upload-file)[\s=]"
ATLASSIAN_WRITE = (
    r"^(?!.*\s(-G|--get)\b)(?=.*\b(curl|wget|http|https|xh)\b)(?=.*" + _ATL + r")(?=.*(" + _WRITE + r"))"
)

ASK = [
    (r"\baws\s+logs\s+(get-log-events|filter-log-events|tail|start-query|get-query-results|get-log-record)\b", "log contents can hold PHI/PII"),
    (r"\baws\s+lambda\s+get-function-configuration\b|\baws\s+lambda\s+get-function\b", "returns env vars, which may hold secrets"),
    (r"\bkubectl\b.*\b(logs|exec|cp|attach|port-forward|debug)\b", "touches workload contents"),
    (r"\bterraform\s+(state\s+(pull|show)|show|output|console)\b|\btofu\s+(state\s+(pull|show)|show|output|console)\b", "state/output can contain secrets"),
    (r"\b(psql|mysql|mariadb|mongosh|mongo|redis-cli|sqlcmd|cqlsh)\b", "connects to a database"),
    (r"\b(cat|less|more|head|tail|bat|grep|rg)\b[^|;&]*(\.tfvars\b|(^|/|\s)\.env(?!\.(example|sample|template|dist))(\.[a-z]+)?\b|\.pem\b|\.p12\b|\.pfx\b|\.key\b)", "file may hold secrets"),
    # Anything that leaves this machine or rewrites history. Local `git commit` is not gated:
    # it is reversible, and the written rule already requires Sos's go before committing.
    (r"\bgit\b[^|;&]*\bpush\b", "git push: code leaves this machine"),
    (r"\bgit\s+(reset\s+--hard|clean\s+-[a-z]*f|branch\s+-D|rebase|filter-branch|filter-repo)\b", "rewrites or discards git history"),
    (r"\brelay-push\.sh\b", "relays a git push through macgraw"),
    (r"\bgh\s+(pr\s+(create|merge|comment|review|edit|close|ready)|issue\s+(create|comment|edit|close)|release\s+create|repo\s+(create|delete|edit))\b", "GitHub write: visible to others"),
    (r"\bgh\s+api\b.*(-X|--method)\s*(POST|PUT|PATCH|DELETE)\b|\bgh\s+api\b.*\s(-f|-F|--field|--raw-field|--input)\s", "GitHub API write"),
    (r"\baws\s+codecommit\s+(create-pull-request|merge-pull-request\S*|update-pull-request\S*|post-comment\S*|put-file|create-commit)\b", "CodeCommit write: visible to the customer"),
    # Confluence / JIRA writes: publishing pages, comments, transitions, edits.
    (ATLASSIAN_WRITE, "Atlassian write: publishes to Confluence or JIRA"),
]


def _strip_commit_message(cmd: str) -> str:
    """Drop commit-message text from `git commit` so words in a message can't trip a rule."""
    if not re.search(r"\bgit\b[^|;&]*\bcommit\b", cmd):
        return cmd
    cmd = re.sub(r"<<-?\s*['\"]?(\w+)['\"]?.*?^\s*\1\s*$", "<<HEREDOC", cmd, flags=re.S | re.M)
    cmd = re.sub(r"(\s(-m|--message)(\s+|=))(\"(\\.|[^\"\\])*\"|'[^']*'|\S+)", r"\1MSG", cmd)
    return cmd


def decide(cmd: str):
    scan = _strip_commit_message(cmd)
    for pattern, why in DENY:
        if re.search(pattern, scan, re.IGNORECASE | re.S):
            return "deny", why
    for pattern, why in ASK:
        if re.search(pattern, scan, re.IGNORECASE | re.S):
            return "ask", why
    return None, None


# Expected decisions. Run `python3 -I guard-bash.py --selftest` after any pattern change.
CASES = {
    # secrets
    "env": "deny", "env | grep TOKEN": "deny", "printenv HOME": "deny",
    "env AWS_PROFILE=x aws sts get-caller-identity": None, "set -euo pipefail; ls": None, "unset FOO": None,
    "echo $ATLASSIAN_TOKEN": "deny", 'echo "${MGHILL_ATLASSIAN_TOKEN:0:4}"': "deny", 'printf "%s" "$TODOIST_API_KEY"': "deny",
    "faws env -A cpg-audit": "deny", 'eval "$(faws env -A cpg-audit)" && aws sts get-caller-identity': None,
    "TF_LOG=DEBUG terraform plan": "deny", "cat ~/.aws/credentials": "deny", "gh auth token": "deny",
    "aws configure export-credentials": "deny",
    # customer data
    "aws secretsmanager get-secret-value --secret-id x": "deny", "aws secretsmanager describe-secret --secret-id x": None,
    "aws ssm get-parameter --name /x --with-decryption": "deny", "aws ssm get-parameter --name /x": None,
    "aws s3 cp s3://b/k .": "deny", "aws s3 cp ./f s3://b/k": None, "aws s3 ls s3://b": None,
    "aws s3api get-object --bucket b --key k o": "deny", "aws dynamodb scan --table-name t": "deny",
    "aws dynamodb describe-table --table-name t": None, "aws cognito-idp list-users --user-pool-id x": "deny",
    "kubectl get secret foo -o yaml": "deny", "kubectl get secrets -A": None, "aws ec2 describe-vpcs": None,
    # gray areas
    "aws logs filter-log-events --log-group-name g": "ask", "aws logs describe-log-groups": None, "kubectl logs pod": "ask",
    "terraform plan": None, "terraform state pull": "ask", "terraform state list": None,
    "cat vars/prod.tfvars": "ask", "cat .env.example": None, "cat .env": "ask", "grep -r foo .": None,
    # git: commit free, push and history rewrites ask, message text ignored
    "git status": None, "git log --oneline": None, 'git commit -m "fix(x): y"': None,
    "git commit -q -F /tmp/msg.txt": None, 'git commit -m "mention faws env and $FAKE_TOKEN"': None,
    "git commit -F - <<'EOF'\nclaude: faws env sin eval\nEOF": None,
    "git push": "ask", "git push -u origin feat": "ask", "git -C repo push origin main": "ask",
    "git rebase -i main": "ask", "git reset --hard HEAD~1": "ask", "git branch -D old": "ask",
    "DOCS/relay-push.sh": "ask",
    # GitHub / CodeCommit
    "gh pr create --title x --body y": "ask", "gh pr view 21": None, "gh pr list": None, "gh api repos/o/r/pulls": None,
    "gh api -X POST repos/o/r/issues": "ask", "gh pr comment 21 --body x": "ask",
    "aws codecommit create-pull-request --title x": "ask", "aws codecommit get-repository --repository-name r": None,
    # Atlassian: reads free, writes ask
    'curl -s -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" "$JIRA_URL/rest/api/3/issue/X"': None,
    'curl -s -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" "$JIRA_URL/rest/api/3/search/jql" -G --data-urlencode "jql=x"': None,
    'curl -s -X POST -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" "$JIRA_URL/rest/api/3/issue/X/comment" -d @c.json': "ask",
    'curl -s -u "$CONFLUENCE_EMAIL:$ATLASSIAN_TOKEN" -X PUT "$CONFLUENCE_URL/wiki/rest/api/content/1" --data @b.json': "ask",
    'curl -s -u u:t "$CONFLUENCE_URL/wiki/rest/api/content/1?expand=body.storage"': None,
    'curl -s -u u:t -H "Content-Type: application/json" --data @p.json "$MGHILL_CONFLUENCE_URL/wiki/rest/api/content"': "ask",
    'curl -X POST https://corpinfollc.atlassian.net/wiki/rest/api/content/1/child/attachment -F file=@x.png': "ask",
    'curl -s -X POST "$JIRA_URL/rest/api/3/issue/X/transitions" --json @t.json': "ask",
    "curl -s https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/index.json": None,
}


def selftest() -> int:
    bad = [(c, e, decide(c)[0]) for c, e in CASES.items() if decide(c)[0] != e]
    for c, e, g in bad:
        print(f"FAIL expected={e} got={g}: {c!r}")
    print(f"{len(CASES) - len(bad)}/{len(CASES)} pass")
    return 1 if bad else 0


def main() -> int:
    if "--selftest" in sys.argv:
        return selftest()
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0
    if payload.get("tool_name") != "Bash":
        return 0
    cmd = payload.get("tool_input", {}).get("command", "")
    decision, why = decide(cmd)
    if decision is None:
        return 0
    if decision == "deny":
        reason = (f"guard-bash: blocked, {why}. Inspect infrastructure, never its contents. "
                  "If this is genuinely needed, stop and ask Sos to run it himself.")
    else:
        reason = f"guard-bash: {why}. Confirm this specific call."
    json.dump({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": decision,
        "permissionDecisionReason": reason,
    }}, sys.stdout)
    return 0


if __name__ == "__main__":
    sys.exit(main())
