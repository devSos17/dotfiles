#!/bin/bash
# Helpers de Bitwarden — agnosticos del cliente.
# Sourced por: tmux/scripts/bitwarden.sh, shell/hooks/*
#
# Cliente preferido: rbw (agente en memoria, lock_timeout, nada en disco).
# Fallback: bw (CLI oficial) para distros sin rbw en repos — debian 12,
# ubuntu 24.04 LTS. Ver .chezmoidata/packages.yaml.
#
# INVARIANTE DE SEGURIDAD: la llave maestra del vault NUNCA va al entorno
# ni a opciones de tmux. Con rbw vive solo en memoria del agente. Solo los
# valores individuales de ~/.config/secrets/* se cachean en el env de tmux.

# ---------------------------------------------------------------------------
# vault_client — imprime "rbw" | "bw" | "" (ninguno disponible)
# ---------------------------------------------------------------------------
vault_client() {
    if command -v rbw >/dev/null 2>&1; then
        echo "rbw"
    elif command -v bw >/dev/null 2>&1; then
        echo "bw"
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# vault_unlocked — exit 0 si el vault esta desbloqueado y usable
# ---------------------------------------------------------------------------
vault_unlocked() {
    case "$(vault_client)" in
        rbw) rbw unlocked >/dev/null 2>&1 ;;
        bw)
            [ -n "$BW_SESSION" ] || return 1
            [ "$(bw status 2>/dev/null \
                | python3 -c 'import sys,json; print(json.load(sys.stdin).get("status",""))' \
                2>/dev/null)" = "unlocked" ]
            ;;
        *) return 1 ;;
    esac
}

# ---------------------------------------------------------------------------
# vault_unlock — desbloquea (interactivo). Con rbw el agente persiste la
# llave durante lock_timeout, asi que basta una vez por maquina/timeout.
# ---------------------------------------------------------------------------
vault_unlock() {
    case "$(vault_client)" in
        rbw)
            # pinentry se encarga del prompt (grafico o curses segun entorno).
            # El agente arranca solo en el primer comando que necesite llaves.
            rbw unlock || return 1
            rbw sync >/dev/null 2>&1 || true
            return 0
            ;;
        bw)
            # Fallback: bw no tiene agente, hay que cargar BW_SESSION a mano.
            # Ojo: cada `bw unlock` invalida la session key anterior.
            local token
            token=$(bw unlock --raw) || return 1
            [ -n "$token" ] || return 1
            export BW_SESSION="$token"
            return 0
            ;;
        *)
            echo "✗ No hay cliente de Bitwarden (ni rbw ni bw)" >&2
            return 1
            ;;
    esac
}

# ---------------------------------------------------------------------------
# vault_field <item> [field]
# Lee un custom field de un item. <item> acepta nombre, URI o UUID.
# Default: field "token".
# ---------------------------------------------------------------------------
vault_field() {
    local item="$1" field="${2:-token}"
    [ -n "$item" ] || return 1
    case "$(vault_client)" in
        rbw) rbw get "$item" --field "$field" 2>/dev/null ;;
        bw)
            bw get item "$item" 2>/dev/null | python3 -c "
import sys, json
field = sys.argv[1]
try:
    fields = json.load(sys.stdin).get('fields') or []
except Exception:
    sys.exit(0)
print(next((f['value'] for f in fields if f['name'] == field), ''))" "$field" 2>/dev/null
            ;;
        *) return 1 ;;
    esac
}

# Alias retrocompatible (scripts viejos pueden llamar bw_field)
bw_field() { vault_field "$@"; }

# ---------------------------------------------------------------------------
# load_secrets [--verbose]
# Lee ~/.config/secrets/* (formato: ENV_VAR item [field]), resuelve cada uno
# contra el vault, exporta al proceso actual y cachea en el env global de
# tmux (cache de rendimiento: evita N llamadas al vault por shell nuevo).
# Requiere vault desbloqueado. Marca SECRETS_LOADED al terminar.
# ---------------------------------------------------------------------------
load_secrets() {
    local verbose=false
    [ "$1" = "--verbose" ] && verbose=true

    local secrets_dir="$HOME/.config/secrets"
    [ -d "$secrets_dir" ] || return 0
    [ -n "$(vault_client)" ] || return 0

    if ! vault_unlocked; then
        $verbose && echo "✗ Vault bloqueado — desbloquea primero"
        return 1
    fi

    $verbose && echo "Cargando secretos del vault ($(vault_client))..."
    local var_name item field_name val loaded=0 failed=0 secretfile
    for secretfile in "$secrets_dir"/*; do
        [ -f "$secretfile" ] || continue
        while read -r var_name item field_name; do
            [ -z "$var_name" ] && continue
            case "$var_name" in \#*) continue ;; esac
            $verbose && echo "  ⏳ $var_name"
            val=$(vault_field "$item" "${field_name:-token}")
            if [ -n "$val" ]; then
                export "$var_name=$val"
                [ -n "$TMUX" ] && tmux setenv -g "$var_name" "$val" 2>/dev/null
                $verbose && echo "  ✓ $var_name"
                loaded=$((loaded + 1))
            else
                $verbose && echo "  ✗ $var_name (vacio o no encontrado)"
                failed=$((failed + 1))
            fi
        done < "$secretfile"
    done

    if [ "$failed" -eq 0 ] && [ -n "$TMUX" ]; then
        tmux setenv -g SECRETS_LOADED true 2>/dev/null
        # Reinicia el guard del warning (ver hooks/pre/environment)
        tmux setenv -gu _BW_WARNED 2>/dev/null
    fi
    $verbose && echo "" && echo "✓ $loaded secreto(s) cargado(s)$([ "$failed" -gt 0 ] && echo ", $failed fallido(s)")"
    return 0
}

# Alias retrocompatible
load_secrets_to_tmux() { load_secrets "$@"; }

# ---------------------------------------------------------------------------
# Primitivas para el picker interactivo (tmux/scripts/bitwarden.sh)
# ---------------------------------------------------------------------------

# vault_list — nombres de items, uno por linea
vault_list() {
    case "$(vault_client)" in
        rbw) rbw ls 2>/dev/null ;;
        bw)  bw list items 2>/dev/null | jq -r '.[].name' ;;
        *)   return 1 ;;
    esac
}

# vault_password <item>
vault_password() {
    case "$(vault_client)" in
        rbw) rbw get "$1" 2>/dev/null ;;
        bw)  bw get password "$1" 2>/dev/null ;;
        *)   return 1 ;;
    esac
}

# vault_totp <item> — falla si el item no tiene TOTP
vault_totp() {
    case "$(vault_client)" in
        rbw) rbw code "$1" 2>/dev/null ;;
        bw)  bw get totp "$1" 2>/dev/null ;;
        *)   return 1 ;;
    esac
}
