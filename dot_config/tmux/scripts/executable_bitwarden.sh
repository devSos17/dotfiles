#!/bin/bash 

set -e

function send_message {
    echo "${@}"
    tmux display-message "${@}"
}


function check_dependecies {
    dependencies=("bw" "jq" "fzf")
    for dep in ${dependencies[@]}; do
        if ! command -v $dep  &> /dev/null; then
            send_message "Missing Dependency: $dep" 
            exit 1
        fi
    done
}

function get_bw_items {
    # Only get those from type 1 (Logins) | get user -> id
    filter='map({ (.name|tostring): {"id": .id, "totp": (.login.totp != null) } }) | add'
    filter+=$1 # Add extra querys
    bw list items | jq -r "$filter"
}


function get_id {
    local items="${1:-$(get_bw_items)}"
    local key="${2:-$(get_key "$items")}"
    # items=$(get_bw_items)
    echo "$items" | jq -r ".\"$key\".id" 
}

function has_totp {
    local key=$1
    local items="$(get_bw_items)"
    # items=$(get_bw_items)
    totp=$(echo "$items" | jq -r ".\"$key\".totp")
    [[ $totp  == "true" ]]
}

function get_key {
    local items="${1:-$(get_bw_items)}"
    echo "$items" | jq -r '.|keys[]' | fzf --no-multi | tr -d '":'
}

function unlock {
    # if unlocked do nothing
    if [[ $(bw status | jq -r '.status') == "unlocked" ]]; then
        send_message "✓ Already unlocked"
        return
    else 
        echo "Vault locked - need to unlock"
    fi
    
    bw_token=$(tmux show -gqv "@bw_session")
    
    # If we have a stored token, try to use it
    if [[ -n $bw_token ]]; then
        export BW_SESSION="$bw_token"
        if [[ $(bw status | jq -r '.status') == "unlocked" ]]; then
            send_message "✓ Unlocked with stored session"
            tmux setenv -g BW_SESSION "$bw_token"
            return
        else
            # Token is invalid, remove it
            tmux set -gu "@bw_session"
            bw_token=""
        fi
    fi
    
    # Need to unlock with password
    echo "Enter master password to unlock vault"
    echo "─────────────────────────────────────"
    if ! bw_token=$(bw unlock --raw); then
        send_message "✗ Authentication failed"
        exit 1
    fi
    
    # Validate token
    if [[ -z $bw_token ]]; then
        send_message "✗ Empty token received"
        exit 1
    fi
    
    # Save token and export
    tmux set -g "@bw_session" "$bw_token"
    tmux setenv -g BW_SESSION "$bw_token"
    export BW_SESSION="$bw_token"
    
    send_message "✓ Vault unlocked successfully"
}

function main {
    [[ -z $TMUX ]] && echo "TMUX script, run in tmux" && exit 1
    check_dependecies
    unlock

    declare result
    command=$1
    # echo "Command:$command"
    case "$command" in
        "unlock") 
            send_message "Unlocked, source bitwarden alias"
            exit 0
            ;;
        "totp") 
            id=$(get_id "$(get_bw_items "| map_values(select(.totp))")") || exit
            result=$(bw get totp $id)
            ;;
        "password"|"pass") 
            id=$(get_id) || exit
            result=$(bw get password $id)
            ;;
        "all") 
            items=$(get_bw_items)
            key=$(get_key "$items")
            if has_totp $key; then
                    totp=$(bw get totp "$(get_id "$items" "$key")")
            fi
            pass=$(bw get password "$(get_id "$items" "$key")")
            tmux send-keys "${pass}"
            tmux send-keys "${totp}"
            exit 0
            ;;
        *)
            # get id 
            items=$(get_bw_items)
            key=$(get_key "$items")
            if has_totp $key; then
                option=$(echo -e "totp\npassword" | fzf --no-multi)
                [[ $option == "totp" ]] \
                    && result=$(bw get totp "$(get_id "$items" "$key")")
            fi
            result=$(bw get password "$(get_id "$items" "$key")")
            ;;
    esac
    # Insert into last pane
    tmux send-keys "${result}"
}

## Wrapper 
main ${@}

