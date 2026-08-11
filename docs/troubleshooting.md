# Troubleshooting

## Rollback

The installed system has no snapshots (ext4 root), so backups are NixOS generations.

- **Boot to an older generation**: pick it from the systemd-boot menu at boot.
- **Roll back system + home**: `sudo nixos-rebuild switch --rollback`
- **Roll back only home**: `nix profile rollback --profile /nix/var/nix/profiles/per-user/$USER`
- **Keep old generations available**: `nix-collect-garbage --delete-older-than 30d` (matches the automatic weekly GC, never `--delete-older-than 0d` unless you want all history gone)

## Recovery (broken system)

If the system won't boot and no boot-menu generation helps, recover from the NixOS installer ISO:

```bash
# 1. Boot the installer, then identify partitions
lsblk -f

# 2. Mount root and boot (by-id paths, see the host's disko.nix under hosts/<host>/)
mount /dev/disk/by-id/<root-part> /mnt
mount /dev/disk/by-id/<boot-part> /mnt/boot

# 3. Enter the installed system and rebuild from a repo copy
nixos-enter --root /mnt
git clone <repo-url> /tmp/nixos-dots && cd /tmp/nixos-dots
nixos-rebuild switch --flake .#<host>
```

If the disk itself is damaged beyond repair, reinstall from scratch: `./install/install.sh <host>`. This wipes the disk — per-host notes may apply, see [Aspire 7](aspire7.md).

For day-to-day rebuilds and validation: [maintenance.md](maintenance.md).