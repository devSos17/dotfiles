#!/usr/bin/env bash
# /usr/local/bin/secureboot-sign.sh
# Regenera grubx64.efi como standalone con .sbat nativo (grub-mkstandalone)
# y firma kernel+grub con MOK tras upgrades de linux/grub.
# NUNCA usa objcopy: GNU objcopy produce PEs malformados (VMA=0) que shim
# no puede cargar ni con Secure Boot apagado. Lección aprendida 2026-06-26.
set -euo pipefail

MOK_KEY="/etc/secureboot/mok/mok.key"
MOK_CERT="/etc/secureboot/mok/mok.crt"
GRUB_SBAT="/etc/secureboot/mok/grub-sbat.csv"
GRUB_EFI="/boot/EFI/BOOT/grubx64.efi"
BOOTX64="/boot/EFI/BOOT/BOOTX64.EFI"
SHIM="/usr/share/shim-signed/shimx64.efi"
MM_SRC="/usr/share/shim-signed/mmx64.efi"
MM_DST="/boot/EFI/BOOT/mmx64.efi"
VMLINUZ="/boot/vmlinuz-linux"
ESP_UUID="C536-0EAF"
TAG="secureboot-sign"

log() { echo "[$TAG] $*"; }
die() { echo "[$TAG] ERROR: $*" >&2; exit 1; }

[[ -f "$MOK_KEY" && -f "$MOK_CERT" && -s "$GRUB_SBAT" ]] \
  || die "faltan MOK key/cert o sbat csv en /etc/secureboot/mok/"

# 1. Restaurar layout shim si grub-install pisó BOOTX64.EFI (shim ~1MB, grub <1MB... el standalone es ~6MB, así que comparamos contra shim mismo)
if ! cmp -s "$BOOTX64" "$SHIM"; then
    log "BOOTX64.EFI != shim — restaurando layout shim"
    cp "$SHIM" "$BOOTX64"
    cp "$MM_SRC" "$MM_DST" 2>/dev/null || true
fi

# 2. Regenerar grub standalone con .sbat nativo
EMB=$(mktemp); NEW=$(mktemp /tmp/grubx64-XXXX.efi); SIGNED=$(mktemp /tmp/grubx64-signed-XXXX.efi)
trap 'rm -f "$EMB" "$NEW" "$SIGNED"' EXIT
printf 'search --no-floppy --set=root --fs-uuid %s\nconfigfile ($root)/grub/grub.cfg\n' "$ESP_UUID" > "$EMB"

grub-mkstandalone \
  --format=x86_64-efi --output="$NEW" --sbat="$GRUB_SBAT" \
  --modules="part_gpt part_msdos fat ext2 normal search search_fs_uuid configfile all_video gfxterm linux gzio echo test" \
  "boot/grub/grub.cfg=$EMB" || die "grub-mkstandalone falló"

# 3. Gate: .sbat sano ANTES de firmar
VMA=$(objdump -h "$NEW" | awk '/\.sbat/{print $4; exit}')
[[ -n "$VMA" && "$VMA" != "0000000000000000" ]] || die ".sbat ausente o VMA=0 — NO se instala"

# 4. Firmar con gate anti-PE-malformado
OUT=$(sbsign --key "$MOK_KEY" --cert "$MOK_CERT" --output "$SIGNED" "$NEW" 2>&1) || die "sbsign: $OUT"
echo "$OUT" | grep -qiE "checksum areas|Invalid section table|gap in the section" && die "PE malformado: $OUT"
sbverify --cert "$MOK_CERT" "$SIGNED" >/dev/null || die "sbverify rechazó el grub"

# 5. Instalar (el grub actual queda como .prev)
cp "$GRUB_EFI" "${GRUB_EFI}.prev" 2>/dev/null || true
cp "$SIGNED" "$GRUB_EFI"
sbverify --cert "$MOK_CERT" "$GRUB_EFI" >/dev/null || die "instalado no verifica"
log "grub standalone instalado y verificado"

# 6. Firmar kernel
if [[ -f "$VMLINUZ" ]]; then
    sbsign --key "$MOK_KEY" --cert "$MOK_CERT" --output "$VMLINUZ" "$VMLINUZ" >/dev/null 2>&1 \
      || die "no se pudo firmar $VMLINUZ"
    sbverify --cert "$MOK_CERT" "$VMLINUZ" >/dev/null 2>&1 \
      || die "kernel firmado no verifica"
    log "kernel firmado y verificado"
fi

log "Done."
