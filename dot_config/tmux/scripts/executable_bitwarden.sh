#!/bin/bash

# Bitwarden integration for tmux
# Commands: unlock, pass, totp, all, load-secrets
# Used by: prefix+b menu, bw-load shell function

function send_message {
    echo "${@}"
    tmux display-message "${@}" 2>/dev/null
}

function check_dependencies {
    local dependencies=("bw" "jq" "fzf")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            send_message "Missing Dependency: $dep"
            exit 1
        fi
    done
}

# Source shared helpers
_helpers="$HOME/.config/shell/lib/bw-helpers.sh"
if [[ -f "$_helpers" ]]; then
    source "$_helpers"
else
    echo "ERROR: Missing $_helpers" >&2
    exit 1
fi
unset _helpers

# ---------------------------------------------------------------------------
# Vault item helpers (for pass/totp/all commands)
# ---------------------------------------------------------------------------
function get_bw_items {
    local filter='map({ (.name|tostring): {"id": .id, "totp": (.login.totp != null) } }) | add'
    filter+=${1:-}
    bw list items | jq -r "$filter"
}

function get_id {
    local items="${1:-$(get_bw_items)}"
    local key="${2:-$(get_key "$items")}"
    echo "$items" | jq -r ".\"$key\".id"
}

function has_totp {
    local key="$1"
    local items="$2"
    local totp
    totp=$(echo "$items" | jq -r ".\"$key\".totp")
    [[ "$totp" == "true" ]]
}

function get_key {
    local items="${1:-$(get_bw_items)}"
    echo "$items" | jq -r '.|keys[]' | fzf --no-multi | tr -d '":'
}

# ---------------------------------------------------------------------------
# unlock — Ensure BW vault is unlocked, prompt if needed
# ---------------------------------------------------------------------------
function unlock {
    local status
    status=$(bw status 2>/dev/null | jq -r '.status')

    if [[ "$status" == "unlocked" ]]; then
        echo "✓ Already unlocked"
        return 0
    fi

    echo "🔒 Bitwarden vault locked"
    echo ""

    # Try stored session token first
    local bw_token
    bw_token=$(tmux show -gqv "@bw_session" 2>/dev/null)

    if [[ -n "$bw_token" ]]; then
        echo "  Trying stored session..."
        export BW_SESSION="$bw_token"
        status=$(bw status 2>/dev/null | jq -r '.status')
        if [[ "$status" == "unlocked" ]]; then
            echo "  ✓ Unlocked with stored session"
            tmux setenv -g BW_SESSION "$bw_token" 2>/dev/null
            return 0
        fi
        echo "  ✗ Stored session expired"
        tmux set -gu "@bw_session" 2>/dev/null
    fi

    # 3 attempts, Ctrl-C to bail
    local attempt
    for attempt in 1 2 3; do
        echo ""
        echo "  Enter master password (attempt $attempt/3)"
        echo "  ─────────────────────────────────────"
        # Use bw's own interactive prompt (works in tmux display-popup PTY)
        if bw_token=$(bw unlock --raw); then
            if [[ -n "$bw_token" ]]; then
                # Save and export
                tmux set -g "@bw_session" "$bw_token" 2>/dev/null
                tmux setenv -g BW_SESSION "$bw_token" 2>/dev/null
                export BW_SESSION="$bw_token"
                echo ""
                echo "  ✓ Vault unlocked successfully"
                return 0
            fi
        fi
        echo "  ✗ Authentication failed"
        (( attempt < 3 )) && echo "  Retrying..."
    done

    echo ""
    echo "  ✗ 3 failed attempts. Use prefix+b to try again."
    return 1
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
function main {
    local cmd="$1"

    # ── load-secrets: standalone, vault must be unlocked ──
    if [[ "$cmd" == "load-secrets" ]]; then
        [[ -z "$TMUX" ]] && echo "Must run inside tmux" && exit 1
        command -v bw &>/dev/null || { echo "bw not found"; exit 1; }
        load_secrets_to_tmux --verbose
        exit 0
    fi

    # ── unlock-and-load: used by bw-load shell function ──
    if [[ "$cmd" == "unlock-and-load" ]]; then
        [[ -z "$TMUX" ]] && echo "Must run inside tmux" && exit 1
        command -v bw &>/dev/null || { echo "bw not found on PATH"; exit 1; }

        if unlock; then
            echo ""
            load_secrets_to_tmux --verbose
            echo ""
            echo "Press Enter to close..."
            read -r
        else
            echo ""
            echo "Press Enter to close..."
            read -r
        fi
        exit 0
    fi

    # ── Normal interactive commands (from prefix+b menu) ──
    [[ -z "$TMUX" ]] && echo "Must run inside tmux" && exit 1
    check_dependencies
    unlock || exit 1

    declare result
    case "$cmd" in
        "unlock")
            load_secrets_to_tmux --verbose
            echo ""
            echo "Press Enter to close..."
            read -r
            send_message "Unlocked, secrets loaded"
            exit 0
            ;;
        "totp")
            local id
            id=$(get_id "$(get_bw_items '| map_values(select(.totp))')") || exit
            result=$(bw get totp "$id")
            ;;
        "password"|"pass")
            local id
            id=$(get_id) || exit
            result=$(bw get password "$id")
            ;;
        "all")
            local items key id
            items=$(get_bw_items)
            key=$(get_key "$items")
            id=$(get_id "$items" "$key")
            if has_totp "$key" "$items"; then
                local totp
                totp=$(bw get totp "$id")
            fi
            local pass
            pass=$(bw get password "$id")
            tmux send-keys "${pass}" Enter
            [[ -n "${totp:-}" ]] && tmux send-keys "${totp}" Enter
            exit 0
            ;;
        *)
            local items key
            items=$(get_bw_items)
            key=$(get_key "$items")
            if has_totp "$key" "$items"; then
                local option
                option=$(echo -e "totp\npassword" | fzf --no-multi)
                [[ "$option" == "totp" ]] \
                    && result=$(bw get totp "$(get_id "$items" "$key")")
            fi
            [[ -z "$result" ]] && result=$(bw get password "$(get_id "$items" "$key")")
            ;;
    esac

    # Send result to last pane
    tmux send-keys "${result}" Enter
}

main "${@}"
