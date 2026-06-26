#!/usr/bin/env bash
# /usr/local/bin/secureboot-sign.sh
# Re-signs EFI binaries with the MOK key after linux or grub upgrades.
# Called by the zz-secureboot-sign pacman hook.
# Safe to run multiple times (idempotent: sbsign overwrites in place).

set -euo pipefail

MOK_KEY="/etc/secureboot/mok/mok.key"
MOK_CERT="/etc/secureboot/mok/mok.crt"
GRUB_EFI="/boot/EFI/BOOT/grubx64.efi"
VMLINUZ="/boot/vmlinuz-linux"
LOG_TAG="secureboot-sign"

log() { echo "[${LOG_TAG}] $*"; }
err() { echo "[${LOG_TAG}] ERROR: $*" >&2; }

sign_if_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        err "File not found, skipping: $file"
        return 0
    fi
    log "Signing: $file"
    sbsign --key "$MOK_KEY" --cert "$MOK_CERT" --output "$file" "$file" 2>&1 \
        && log "OK: $file" \
        || { err "Failed to sign $file"; return 1; }
    sbverify --cert "$MOK_CERT" "$file" >/dev/null 2>&1 \
        && log "Verified: $file" \
        || { err "Verification FAILED for $file — system may be unbootable under Secure Boot!"; return 1; }
}

# When grub is upgraded it may overwrite /boot/EFI/BOOT/BOOTX64.EFI (the
# removable path) rather than grubx64.efi.  Detect this and restore the layout.
fix_grub_overwrite() {
    local bootx64="/boot/EFI/BOOT/BOOTX64.EFI"
    local shimx64="/usr/share/shim-signed/shimx64.efi"
    # If BOOTX64.EFI is smaller than shim (~1MB), grub rewrote it.
    # Shim is ~1MB; GRUB is ~150-300KB.
    local size
    size=$(stat -c%s "$bootx64" 2>/dev/null || echo 0)
    if [[ "$size" -lt 500000 ]]; then
        log "Detected GRUB overwrite of BOOTX64.EFI (size=${size}). Restoring shim layout."
        cp "$bootx64" /boot/EFI/BOOT/grubx64.efi
        cp "$shimx64" "$bootx64"
        log "Shim layout restored."
    fi
}

main() {
    log "Starting Secure Boot signing pass."

    if [[ ! -f "$MOK_KEY" || ! -f "$MOK_CERT" ]]; then
        err "MOK key/cert not found at /etc/secureboot/mok/ — skipping signing."
        exit 1
    fi

    # Only fix layout if grub package was the trigger (BOOTX64.EFI might be stale)
    if [[ -f /boot/EFI/BOOT/BOOTX64.EFI ]]; then
        fix_grub_overwrite
    fi

    sign_if_exists "$GRUB_EFI"
    sign_if_exists "$VMLINUZ"

    log "Done."
}

main "$@"
