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

# 4. Private key (from encrypted backup)
#    Decrypt the age-encrypted file and install with tight permissions:
age --decrypt -i ~/.config/chezmoi/key.txt \
    oth/secureboot/etc/secureboot/mok/mok.key.age \
    | sudo install -Dm600 /dev/stdin /etc/secureboot/mok/mok.key

# 5. Enroll the MOK if not already enrolled (only needed on fresh install):
#    sudo mokutil --import /etc/secureboot/mok/mok.crt
#    (then reboot and confirm the MOK enrollment password at the shim screen)
```

## File inventory

| Source path (in this repo)                              | System path                               | Perms | Secret? |
|---------------------------------------------------------|-------------------------------------------|-------|---------|
| oth/secureboot/usr/local/bin/secureboot-sign.sh         | /usr/local/bin/secureboot-sign.sh         | 0755  | No      |
| oth/secureboot/etc/pacman.d/hooks/zz-secureboot-sign.hook | /etc/pacman.d/hooks/zz-secureboot-sign.hook | 0644 | No   |
| oth/secureboot/etc/secureboot/mok/mok.crt               | /etc/secureboot/mok/mok.crt               | 0644  | No (public cert) |
| oth/secureboot/etc/secureboot/mok/mok.cer               | /etc/secureboot/mok/mok.cer               | 0644  | No (public cert, DER) |
| oth/secureboot/etc/secureboot/mok/mok.key.age           | /etc/secureboot/mok/mok.key               | 0600  | YES — age-encrypted |

## Updating after kernel/grub upgrade

The pacman hook runs automatically. If you need to trigger it manually:
```sh
sudo /usr/local/bin/secureboot-sign.sh
```
