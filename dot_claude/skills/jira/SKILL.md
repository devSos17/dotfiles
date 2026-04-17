---
name: jira
description: Query JIRA tickets — sprint, search, ticket details
allowed-tools: Bash
---

Query JIRA using the REST API. Auth via env vars `JIRA_URL`, `JIRA_EMAIL`, `ATLASSIAN_TOKEN`.

Base URL: `$JIRA_URL` (https://nbdevs.atlassian.net)
Projects: VOH, RBNA, PURE, RSCH, DOS, IRECAR, OPTA, AONCAR, METERCAR
Story points field: `customfield_10004`

## Usage

`/jira <command> [args]`

### Commands

**sprint** — Current sprint tickets assigned to me
```
/jira sprint
/jira sprint DOS
```

**ticket <ID>** — Full ticket details (description, status, SP, comments)
```
/jira ticket DOS-740
```

**search <JQL>** — Run a JQL query
```
/jira search project = DOS AND status = "In Progress"
```

## Implementation

Use `curl` with basic auth (`$JIRA_EMAIL:$ATLASSIAN_TOKEN`). Parse with `python3 -c` for JSON handling.

### Sprint query
```bash
curl -s -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" \
  "$JIRA_URL/rest/api/3/search/jql" \
  -G --data-urlencode "jql=assignee = currentUser() AND sprint in openSprints() ORDER BY priority DESC" \
  --data-urlencode "fields=summary,status,priority,customfield_10004,project,issuetype" \
  -H "Accept: application/json"
```
Response shape: `{ "issues": [...], "isLast": bool }` — no `total` field.

If a project key is passed (e.g., `/jira sprint DOS`), add `AND project = <KEY>` to the JQL.

### Ticket details
```bash
curl -s -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" \
  "$JIRA_URL/rest/api/3/issue/<TICKET_ID>" \
  -H "Accept: application/json"
```

Extract: summary, status, priority, story points (`customfield_10004`), description (convert ADF to plain text), assignee, reporter, and last 5 comments.

### Search
```bash
curl -s -u "$JIRA_EMAIL:$ATLASSIAN_TOKEN" \
  "$JIRA_URL/rest/api/3/search/jql" \
  -G --data-urlencode "jql=<USER_JQL>" \
  --data-urlencode "fields=summary,status,priority,customfield_10004,project" \
  -H "Accept: application/json"
```

### Note on DOS tickets
DOS project tickets are accessed via their parent project key (e.g., DOS-740 is `RBNA-1076` in JIRA). If a DOS ticket returns "does not exist", search by summary or try the RBNA/customer project key.

## Output format

Present results as a clean table. For sprint:

| Key | Summary | Status | SP | Priority |
|-----|---------|--------|----|----------|

For ticket details: show all fields in a readable format, description as markdown, comments chronologically.
