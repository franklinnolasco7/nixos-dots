# Troubleshooting

## Rollback

Backups are NixOS generations (ext4 root, no snapshots).

- Older generation: pick from systemd-boot menu
- System + home: `sudo nixos-rebuild switch --rollback`
- Home only: `nix profile rollback --profile /nix/var/nix/profiles/per-user/$USER`
- Keep history: `nix-collect-garbage --delete-older-than 30d`

## Recovery

Won't boot, no generation helps → USB installer ISO:

```bash
lsblk -f                                                   # find partitions
mount /dev/disk/by-id/<root-part> /mnt                     # see hosts/<host>/disko.nix
mount /dev/disk/by-id/<boot-part> /mnt/boot
nixos-enter --root /mnt                                    # enter installed system
git clone <repo-url> /tmp/nixos-dots && cd /tmp/nixos-dots
nixos-rebuild switch --flake .#<host>
```

Disk dead → reinstall: `./install/install.sh <host>` (wipes). Per-host: [Aspire 7](aspire7.md).

Daily ops: [maintenance.md](maintenance.md).