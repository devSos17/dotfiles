#!/usr/bin/env bash
# Harness de VMs para probar bootstrap.sh multi-distro end-to-end.
# Usa libvirt (qemu:///system, pool "default", red NAT "default") sin sudo
# (requiere estar en el grupo libvirt).
#
# Uso:
#   ./test-vm.sh <ubuntu|debian|fedora> up       # crea y arranca la VM (cloud image + cloud-init)
#   ./test-vm.sh <distro> run [rama]             # scp bootstrap.sh + lo corre via ssh (NO_SECRETS=1 GUI=0)
#   ./test-vm.sh <distro> ssh                    # shell en la VM
#   ./test-vm.sh <distro> ip                     # muestra la IP
#   ./test-vm.sh <distro> destroy                # apaga, undefine y borra el overlay (la base queda cacheada)
#   ./test-vm.sh <distro> recreate               # destroy + up (iteracion rapida)
set -euo pipefail

DISTRO="${1:?uso: $0 <ubuntu|debian|fedora> <up|run|ssh|ip|destroy|recreate>}"
ACTION="${2:?uso: $0 <ubuntu|debian|fedora> <up|run|ssh|ip|destroy|recreate>}"

VIRSH="virsh -c qemu:///system"
POOL="default"
VM="bt-$DISTRO"
BASE_VOL="bt-base-$DISTRO.qcow2"
OVERLAY_VOL="bt-$DISTRO.qcow2"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/bootstrap-test"
SSH_USER="walker"
SSH_OPTS=(-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5)
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

case "$DISTRO" in
  ubuntu) IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img" ;;
  debian) IMG_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2" ;;
  fedora)
    # el nombre exacto del qcow2 cambia por respin -> resolverlo del listing
    FEDORA_REL="${FEDORA_REL:-43}"
    FEDORA_DIR="https://download.fedoraproject.org/pub/fedora/linux/releases/${FEDORA_REL}/Cloud/x86_64/images"
    ;;
  *) echo "distro no soportada: $DISTRO" >&2; exit 1 ;;
esac

log() { printf '\033[1;34m::\033[0m %s\n' "$*"; }

vm_ip() {
  $VIRSH domifaddr "$VM" 2>/dev/null | awk '/ipv4/ {sub(/\/.*/,"",$4); print $4; exit}'
}

wait_ssh() {
  local ip="" i
  log "esperando IP + ssh..."
  for i in $(seq 1 60); do
    ip="$(vm_ip)"
    if [ -n "$ip" ] && ssh "${SSH_OPTS[@]}" "$SSH_USER@$ip" true 2>/dev/null; then
      echo "$ip"; return 0
    fi
    sleep 3
  done
  echo "timeout esperando ssh a $VM" >&2; return 1
}

do_up() {
  mkdir -p "$CACHE"

  # --- resolver URL de fedora si aplica ---
  if [ "$DISTRO" = "fedora" ]; then
    local fname
    fname="$(curl -fsSL "$FEDORA_DIR/" | grep -oE 'Fedora-Cloud-Base-Generic-[^"]+\.qcow2' | head -1)"
    [ -n "$fname" ] || { echo "no pude resolver la imagen de fedora $FEDORA_REL" >&2; exit 1; }
    IMG_URL="$FEDORA_DIR/$fname"
  fi

  # --- base image: descargar a cache y subir al pool si no existe ---
  if ! $VIRSH vol-info --pool "$POOL" "$BASE_VOL" >/dev/null 2>&1; then
    local img="$CACHE/$(basename "$IMG_URL")"
    if [ ! -f "$img" ]; then
      log "descargando $IMG_URL"
      curl -fL --progress-bar -o "$img.part" "$IMG_URL" && mv "$img.part" "$img"
    fi
    log "subiendo base al pool $POOL como $BASE_VOL"
    local size
    size=$(stat -c%s "$img")
    $VIRSH vol-create-as "$POOL" "$BASE_VOL" "$size" --format qcow2
    $VIRSH vol-upload --pool "$POOL" "$BASE_VOL" "$img"
  fi

  # --- overlay (disco de la VM, backing = base) ---
  if ! $VIRSH vol-info --pool "$POOL" "$OVERLAY_VOL" >/dev/null 2>&1; then
    log "creando overlay $OVERLAY_VOL (15G, backing $BASE_VOL)"
    $VIRSH vol-create-as "$POOL" "$OVERLAY_VOL" 15G --format qcow2 \
      --backing-vol "$BASE_VOL" --backing-vol-format qcow2
  fi

  # --- cloud-init: usuario + ssh key + curl ---
  local pubkey userdata
  pubkey="$(cat "$HOME/.ssh/walker_rsa.pub" 2>/dev/null || cat "$HOME/.ssh/id_rsa.pub")"
  userdata="$CACHE/user-data-$DISTRO.yaml"
  cat > "$userdata" <<EOF
#cloud-config
hostname: $VM
users:
  - name: $SSH_USER
    groups: [sudo, wheel]
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    ssh_authorized_keys:
      - $pubkey
package_update: true
packages:
  - curl
EOF

  log "creando VM $VM"
  virt-install --connect qemu:///system \
    --name "$VM" \
    --memory 2048 --vcpus 2 \
    --import \
    --disk "vol=$POOL/$OVERLAY_VOL,format=qcow2,bus=virtio" \
    --osinfo detect=on,require=off \
    --network network=default,model=virtio \
    --cloud-init "user-data=$userdata" \
    --graphics none --noautoconsole

  local ip
  ip="$(wait_ssh)"
  log "VM lista: ssh $SSH_USER@$ip"
}

do_run() {
  local branch="${3:-bootstrap-multidistro}"
  local ip
  ip="$(vm_ip)"
  [ -n "$ip" ] || { echo "$VM sin IP (¿esta corriendo?)" >&2; exit 1; }
  log "copiando bootstrap.sh y corriendo (rama $branch, NO_SECRETS=1, GUI=0)"
  scp "${SSH_OPTS[@]}" "$REPO_ROOT/bootstrap.sh" "$SSH_USER@$ip:/tmp/bootstrap.sh"
  # -t: tty real para sudo y prompts; env inline
  ssh -t "${SSH_OPTS[@]}" "$SSH_USER@$ip" \
    "NO_SECRETS=1 GUI=0 DOTS_BRANCH=$branch sh /tmp/bootstrap.sh"
  log "verificacion post-bootstrap:"
  ssh "${SSH_OPTS[@]}" "$SSH_USER@$ip" \
    'export PATH="$HOME/.local/bin:$PATH"; chezmoi --version | head -1; ls ~/.config | head -20; [ -f ~/.zshrc ] && echo ZSHRC_OK; [ -d ~/.config/hypr ] && echo "GUI_LEAK (hypr no debia estar)" || echo GUI_FILTER_OK'
}

case "$ACTION" in
  up)       do_up ;;
  run)      do_run "$@" ;;
  ssh)      ip="$(vm_ip)"; exec ssh "${SSH_OPTS[@]}" "$SSH_USER@$ip" ;;
  ip)       vm_ip ;;
  destroy)
    $VIRSH destroy "$VM" 2>/dev/null || true
    $VIRSH undefine "$VM" 2>/dev/null || true
    $VIRSH vol-delete --pool "$POOL" "$OVERLAY_VOL" 2>/dev/null || true
    log "$VM destruida (base $BASE_VOL queda cacheada en el pool)"
    ;;
  recreate) "$0" "$DISTRO" destroy; "$0" "$DISTRO" up ;;
  *) echo "accion desconocida: $ACTION" >&2; exit 1 ;;
esac
