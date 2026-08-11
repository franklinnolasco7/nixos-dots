# Aspire 7

Host config: `hosts/aspire7/`.

## Hardware

| Component | Detail |
|---|---|
| Disk | SK hynix ~512GB NVMe, by-id: `nvme-HFM512GD3JX016N_FYB3N036910803I0I` (verified, not `/dev/nvme0n1`) |
| GPU | NVIDIA PRIME offload: amdgpu `PCI:5:0:0`, nvidia `PCI:1:0:0` |
| Battery | Acer kernel module (`acer-battery.nix`) |
| Layout | GPT: 1G `/boot` vfat + 8G swap + ext4 root |

> [!WARNING]
> Verify by-id path with `lsblk -f` before destructive Disko runs.

## Install

```bash
sudo bash install/backup-host-key.sh   # detects USB drives and prompts (sops identities)
sudo HOST_KEY_SRC=<backup-dir> ./install/aspire7.sh # Disko wipe + nixos-install
sudo reboot
```

`install/backup-host-key.sh` with no argument scans for removable drives
(`lsblk RM=1`), lets you pick one, mounts it if needed, and saves the backup to
`<mount>/ssh-host-key-backup` — pass that path as `HOST_KEY_SRC`.

Post-install (SSH key, secrets, commit regenerated hardware config):
[installation.md](installation.md#post-install).

## Checklist (fresh install)

```bash
ls ~/wallpapers                          # wallpapers deployed
ls ~/.icons                              # cursor theme
fc-list | grep -iE "jetbrains|noto"      # fonts
ls ~/.config/hypr ~/.config/waybar       # app configs
ls -l ~/.local/bin | grep "^-rwx"        # scripts executable
lsblk -f                                 # disk layout = disko.nix
ls -l ~/.config/opencode/context7-key    # sops secrets decrypted
grep -iE "qemu|virtualbox" /etc/nixos/hardware-configuration.nix   # no VM remnants
```

## Recovery

[troubleshooting.md](troubleshooting.md#recovery) → reinstall: `./install/aspire7.sh`.