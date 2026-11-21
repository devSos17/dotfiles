#!/bin/bash
# Integracion de Bitwarden para tmux
# Comandos: unlock, pass, totp, all, load-secrets, unlock-and-load
# Usado por: menu prefix+b, funcion de shell bw-load
#
# Toda la logica de vault vive en shell/lib/bw-helpers.sh (rbw-first con
# fallback a bw). Este script es solo UI: picker fzf + envio de teclas.

set -o pipefail

# Helpers compartidos
_helpers="$HOME/.config/shell/lib/bw-helpers.sh"
if [[ -f "$_helpers" ]]; then
    # shellcheck source=/dev/null
    source "$_helpers"
else
    echo "ERROR: falta $_helpers" >&2
    exit 1
fi
unset _helpers

function send_message {
    echo "${@}"
    tmux display-message "${@}" 2>/dev/null
}

function check_dependencies {
    local client
    client=$(vault_client)
    if [[ -z "$client" ]]; then
        send_message "Falta dependencia: rbw (o bw como fallback)"
        exit 1
    fi
    if ! command -v fzf &>/dev/null; then
        send_message "Falta dependencia: fzf"
        exit 1
    fi
    # jq solo lo necesita el path de fallback con bw
    if [[ "$client" == "bw" ]] && ! command -v jq &>/dev/null; then
        send_message "Falta dependencia: jq (requerido por el fallback bw)"
        exit 1
    fi
}

# pick_item — elige un item con fzf, imprime su nombre
function pick_item {
    vault_list | fzf --no-multi --prompt="item> " || return 1
}

# ---------------------------------------------------------------------------
# ensure_unlocked — desbloquea si hace falta.
# Con rbw el agente retiene las llaves durante lock_timeout, asi que esto
# normalmente es un no-op tras el primer unlock.
# ---------------------------------------------------------------------------
function ensure_unlocked {
    if vault_unlocked; then
        echo "✓ Vault ya desbloqueado ($(vault_client))"
        return 0
    fi

    echo "🔒 Vault bloqueado ($(vault_client))"
    echo ""
    if vault_unlock; then
        echo ""
        echo "  ✓ Vault desbloqueado"
        return 0
    fi

    echo ""
    echo "  ✗ No se pudo desbloquear. prefix+b para reintentar."
    return 1
}

function pause_and_exit {
    echo ""
    echo "Enter para cerrar..."
    read -r
    exit "${1:-0}"
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
function main {
    local cmd="$1"

    # ── load-secrets: standalone, el vault debe estar abierto ──
    if [[ "$cmd" == "load-secrets" ]]; then
        [[ -z "$TMUX" ]] && { echo "Debe correr dentro de tmux"; exit 1; }
        [[ -z "$(vault_client)" ]] && { echo "Sin cliente de vault"; exit 1; }
        load_secrets --verbose
        exit 0
    fi

    # ── unlock-and-load: usado por la funcion bw-load ──
    if [[ "$cmd" == "unlock-and-load" ]]; then
        [[ -z "$TMUX" ]] && { echo "Debe correr dentro de tmux"; exit 1; }
        [[ -z "$(vault_client)" ]] && { echo "Sin cliente de vault"; exit 1; }
        if ensure_unlocked; then
            echo ""
            load_secrets --verbose
            pause_and_exit 0
        fi
        pause_and_exit 1
    fi

    # ── Comandos interactivos (menu prefix+b) ──
    [[ -z "$TMUX" ]] && { echo "Debe correr dentro de tmux"; exit 1; }
    check_dependencies
    ensure_unlocked || pause_and_exit 1

    local result item
    case "$cmd" in
        "unlock")
            load_secrets --verbose
            send_message "Vault abierto, secretos cargados"
            pause_and_exit 0
            ;;
        "totp")
            item=$(pick_item) || exit 0
            result=$(vault_totp "$item")
            [[ -z "$result" ]] && { send_message "Sin TOTP: $item"; exit 1; }
            ;;
        "password"|"pass")
            item=$(pick_item) || exit 0
            result=$(vault_password "$item")
            ;;
        "all")
            item=$(pick_item) || exit 0
            local pass totp
            pass=$(vault_password "$item")
            totp=$(vault_totp "$item")
            [[ -n "$pass" ]] && tmux send-keys "$pass" Enter
            [[ -n "$totp" ]] && tmux send-keys "$totp" Enter
            exit 0
            ;;
        *)
            item=$(pick_item) || exit 0
            # Ofrece TOTP solo si el item lo tiene
            if totp=$(vault_totp "$item") && [[ -n "$totp" ]]; then
                local option
                option=$(printf 'password\ntotp\n' | fzf --no-multi --prompt="tipo> ")
                [[ "$option" == "totp" ]] && result="$totp"
            fi
            [[ -z "$result" ]] && result=$(vault_password "$item")
            ;;
    esac

    [[ -z "$result" ]] && { send_message "Nada que enviar"; exit 1; }
    # Envia al pane anterior
    tmux send-keys "${result}" Enter
}

main "${@}"
