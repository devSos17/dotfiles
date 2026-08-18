#!/bin/sh
# bootstrap.sh — dotfiles de Sos, entry point multi-distro.
#
# Uso (maquina recien instalada, solo necesitas curl):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/devSos17/dotfiles/main/bootstrap.sh)"
#
# Variables opcionales (exportar antes de correr):
#   GUI=1|0        fuerza el flag gui (default: 1 en arch, 0 en el resto)
#   DOTS_REPO      repo de dotfiles      (default: https://github.com/devSos17/dotfiles.git)
#   DOTS_BRANCH    rama a usar           (default: main)
#   NO_SECRETS=1   modo prueba/VM: no desencripta la age key (--exclude encrypted,
#                  marker no-secrets) y contesta los prompts con placeholders
#
# Cadena: detectar distro -> instalar git+chezmoi -> chezmoi init --apply
# (los run_once de chezmoi se encargan del resto: age key, paquetes, etc.)

set -eu

DOTS_REPO="${DOTS_REPO:-https://github.com/devSos17/dotfiles.git}"
DOTS_BRANCH="${DOTS_BRANCH:-main}"

log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

# --- TTY: bajo `curl | sh` stdin es el pipe; los prompts de chezmoi
# (git_email, passphrase de age) necesitan terminal real.
if [ ! -t 0 ] && [ -e /dev/tty ] && ( exec < /dev/tty ) 2>/dev/null; then
    exec < /dev/tty
fi

# --- Detectar distro -----------------------------------------------------
OS="$(uname -s)"
DISTRO=""
if [ "$OS" = "Darwin" ]; then
    DISTRO="darwin"
elif [ -r /etc/os-release ]; then
    . /etc/os-release
    case "${ID:-} ${ID_LIKE:-}" in
        *arch*)           DISTRO="arch" ;;
        *debian*|*ubuntu*) DISTRO="debian" ;;
        *fedora*|*rhel*)  DISTRO="fedora" ;;
        *) die "distro no soportada: ID=${ID:-?} ID_LIKE=${ID_LIKE:-?}" ;;
    esac
else
    die "no puedo detectar el sistema (sin /etc/os-release)"
fi
log "distro detectada: $DISTRO"

# --- sudo (o root directo) ----------------------------------------------
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo >/dev/null 2>&1 || die "se necesita sudo (o correr como root)"
    SUDO="sudo"
fi

# --- Dependencias minimas: git + chezmoi --------------------------------
install_chezmoi_binary() {
    # debian/ubuntu no empaquetan chezmoi (solo snap) -> binario oficial
    log "instalando chezmoi (get.chezmoi.io) en ~/.local/bin"
    sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$HOME/.local/bin"
    PATH="$HOME/.local/bin:$PATH"
    export PATH
}

case "$DISTRO" in
    arch)
        $SUDO pacman -Sy --needed --noconfirm git chezmoi age
        ;;
    debian)
        $SUDO apt-get update -qq
        $SUDO apt-get install -y -qq git curl age
        command -v chezmoi >/dev/null 2>&1 || install_chezmoi_binary
        ;;
    fedora)
        $SUDO dnf install -y -q git chezmoi age
        ;;
    darwin)
        command -v brew >/dev/null 2>&1 || die "instala Homebrew primero (https://brew.sh)"
        brew list chezmoi >/dev/null 2>&1 || brew install chezmoi age
        ;;
esac
command -v chezmoi >/dev/null 2>&1 || die "chezmoi no quedo en PATH"
log "chezmoi $(chezmoi --version | head -1)"

# --- Flag gui: default por distro, override con GUI=1|0 ------------------
case "$DISTRO" in
    arch) GUI="${GUI:-1}" ;;
    *)    GUI="${GUI:-0}" ;;
esac
[ "$GUI" = "1" ] && GUI_BOOL="true" || GUI_BOOL="false"
log "gui=$GUI_BOOL (GUI=$GUI)"

# --- Init + apply --------------------------------------------------------
# Args extra acumulados en $@ (POSIX sh no tiene arrays)
set -- --branch "$DOTS_BRANCH" --promptBool "gui=$GUI_BOOL"

if [ "${NO_SECRETS:-0}" = "1" ]; then
    log "NO_SECRETS=1: sin age key, sin archivos encriptados, prompts con placeholders"
    mkdir -p "$HOME/.config/chezmoi"
    touch "$HOME/.config/chezmoi/no-secrets"
    set -- "$@" \
        --exclude encrypted \
        --promptBool "secrets=false" \
        --promptString "Enter your git email:=test@example.com" \
        --promptString "Enter your signinkey (leave empty to omit):="
fi

log "chezmoi init --apply $DOTS_REPO (rama $DOTS_BRANCH)"
chezmoi init --apply "$@" "$DOTS_REPO"

log "listo. Revisa: chezmoi status / chezmoi doctor"
log "en arch, el bootstrap de paquetes es opt-in:"
log "  touch ~/.config/chezmoi/bootstrap-enabled && chezmoi state delete-bucket --bucket=scriptState && chezmoi apply"
