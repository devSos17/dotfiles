# Secure Boot MOK Files — Restore Guide

## Absolute path mapping

These files mirror the system layout under `oth/secureboot/`.
On a fresh install, restore with:

```sh
# 1. Script (root-owned, executable)
sudo install -Dm755 oth/secureboot/usr/local/bin/secureboot-sign.sh \
    /usr/local/bin/secureboot-sign.sh

# 2. Pacman hook
sudo install -Dm644 oth/secureboot/etc/pacman.d/hooks/zz-secureboot-sign.hook \
    /etc/pacman.d/hooks/zz-secureboot-sign.hook

# 3. Public certificates
sudo install -Dm644 oth/secureboot/etc/secureboot/mok/mok.crt \
    /etc/secureboot/mok/mok.crt
sudo install -Dm644 oth/secureboot/etc/secureboot/mok/mok.cer \
    /etc/secureboot/mok/mok.cer

# 4. SBAT CSV (required for Secure Boot — shim enforces SBAT on chainloaded binaries)
sudo install -Dm644 oth/secureboot/etc/secureboot/mok/grub-sbat.csv \
    /etc/secureboot/mok/grub-sbat.csv

# 5. Private key (from encrypted backup)
#    Decrypt the age-encrypted file and install with tight permissions:
age --decrypt -i ~/.config/chezmoi/key.txt \
    oth/secureboot/etc/secureboot/mok/mok.key.age \
    | sudo install -Dm600 /dev/stdin /etc/secureboot/mok/mok.key

# 6. Enroll the MOK if not already enrolled (only needed on fresh install):
#    sudo mokutil --import /etc/secureboot/mok/mok.crt
#    (then reboot and confirm the MOK enrollment password at the shim screen)

# 7. Inject .sbat + sign grubx64.efi BEFORE enabling Secure Boot:
#    The signing script handles this automatically (inject_sbat runs before sbsign).
#    To trigger manually:
sudo /usr/local/bin/secureboot-sign.sh
#    Verify:
#    objdump -h /boot/EFI/BOOT/grubx64.efi | grep sbat   # must show .sbat
#    sbverify --cert /etc/secureboot/mok/mok.crt /boot/EFI/BOOT/grubx64.efi
```

## File inventory

| Source path (in this repo)                                   | System path                                  | Perms | Secret? |
|--------------------------------------------------------------|----------------------------------------------|-------|---------|
| oth/secureboot/usr/local/bin/secureboot-sign.sh              | /usr/local/bin/secureboot-sign.sh            | 0755  | No      |
| oth/secureboot/etc/pacman.d/hooks/zz-secureboot-sign.hook    | /etc/pacman.d/hooks/zz-secureboot-sign.hook  | 0644  | No      |
| oth/secureboot/etc/secureboot/mok/mok.crt                    | /etc/secureboot/mok/mok.crt                  | 0644  | No (public cert) |
| oth/secureboot/etc/secureboot/mok/mok.cer                    | /etc/secureboot/mok/mok.cer                  | 0644  | No (public cert, DER) |
| oth/secureboot/etc/secureboot/mok/mok.key.age                | /etc/secureboot/mok/mok.key                  | 0600  | YES — age-encrypted |
| oth/secureboot/etc/secureboot/mok/grub-sbat.csv              | /etc/secureboot/mok/grub-sbat.csv            | 0644  | No      |

## SBAT section requirement

shim-signed >= 15 enforces SBAT strictly: any binary it chainloads (grubx64.efi)
**must** contain a `.sbat` PE section, or shim will show a red "Security Policy
Violation" screen and refuse to boot.

`grub-sbat.csv` defines the SBAT metadata for our grub build. The signing script
(`secureboot-sign.sh`) uses `objcopy` to inject this section into grubx64.efi
**before** signing, every time it runs. This means a `grub` package upgrade that
ships a grub binary without `.sbat` will be fixed automatically on the next pacman
transaction.

The generation numbers in grub-sbat.csv (grub,4 / grub.archlinux,1) are what
shim compares against its revocation list. The firmware SBAT revocation baseline
is `sbat,1,2021030218` — no grub-specific revocations — so any grub generation
number passes. If a future UEFI firmware update revokes grub,4 or lower, update
the generation number and re-run the signing script.

## Updating after kernel/grub upgrade

The pacman hook runs automatically. If you need to trigger it manually:
```sh
sudo /usr/local/bin/secureboot-sign.sh
```

## Recovery if Secure Boot boot fails

If after enabling Secure Boot the system shows the shim red screen:
1. Enter UEFI firmware (Del/F2 at POST).
2. Set OS Type back to "Other OS" (disables Secure Boot).
3. Save and exit — system will boot normally via shim (MOK still enrolled, SB just off).
4. Diagnose: `objdump -h /boot/EFI/BOOT/grubx64.efi | grep sbat` and
   `sbverify --cert /etc/secureboot/mok/mok.crt /boot/EFI/BOOT/grubx64.efi`.
5. Re-run `sudo /usr/local/bin/secureboot-sign.sh` and re-enable SB.
