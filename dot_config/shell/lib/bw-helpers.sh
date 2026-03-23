#!/bin/bash
# Shared Bitwarden helper functions
# Sourced by: bitwarden.sh, shell hooks

# bw_field <bw-item-name> [field-name]
# Fetches a custom field value from a Bitwarden item.
# Defaults to field named "token" if no field specified.
bw_field() {
    local item="$1" field="${2:-token}"
    bw get item "$item" 2>/dev/null | python3 -c "
import sys, json
field = sys.argv[1]
fields = json.load(sys.stdin).get('fields') or []
print(next((f['value'] for f in fields if f['name'] == field), ''))" "$field" 2>/dev/null
}

# load_secrets_to_tmux [--verbose]
# Reads ~/.config/secrets/*, fetches each from BW, pushes to tmux env.
# Requires BW_SESSION to be set and bw unlocked.
# Sets SECRETS_LOADED=true sentinel on success.
load_secrets_to_tmux() {
    local verbose=false
    [[ "$1" == "--verbose" ]] && verbose=true

    local secrets_dir="$HOME/.config/secrets"
    [[ -d "$secrets_dir" ]] || return 0
    command -v bw &>/dev/null || return 0

    # Ensure BW_SESSION is available
    if [[ -z "$BW_SESSION" ]]; then
        local stored_session
        stored_session=$(tmux show -gqv "@bw_session" 2>/dev/null)
        if [[ -n "$stored_session" ]]; then
            export BW_SESSION="$stored_session"
        else
            $verbose && echo "✗ No BW_SESSION available — unlock first"
            return 1
        fi
    fi

    $verbose && echo "Loading secrets from Bitwarden..."
    local var_name bw_item field_name val loaded=0
    for secretfile in "$secrets_dir/"*; do
        [[ -f "$secretfile" ]] || continue
        while read -r var_name bw_item field_name; do
            [[ -z "$var_name" ]] && continue
            [[ "$var_name" = \#* ]] && continue
            $verbose && echo "  ⏳ $var_name"
            val=$(bw_field "$bw_item" "${field_name:-token}")
            if [[ -n "$val" ]]; then
                # Push to tmux env if inside tmux
                if [[ -n "$TMUX" ]]; then
                    tmux setenv "$var_name" "$val" 2>/dev/null
                fi
                # Also export to current process
                export "$var_name=$val"
                $verbose && echo "  ✓ $var_name"
                ((loaded++)) || true
            else
                $verbose && echo "  ✗ $var_name (empty or not found)"
            fi
        done < "$secretfile"
    done

    # Set sentinel
    if [[ -n "$TMUX" ]]; then
        tmux setenv SECRETS_LOADED true 2>/dev/null
    fi
    $verbose && echo "" && echo "✓ Loaded $loaded secret(s)"
    return 0
}
