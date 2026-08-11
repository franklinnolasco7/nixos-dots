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
sudo ./install/aspire7.sh   # Disko wipe + nixos-install
sudo reboot
```

Post-install (SSH key, secrets): [installation.md](installation.md#post-install).

## Checklist (fresh install)

```bash
ls ~/wallpapers                          # wallpapers deployed
ls ~/.icons                              # cursor theme
fc-list | grep -iE "jetbrains|noto"      # fonts
ls ~/.config/hypr ~/.config/waybar       # app configs
ls -l ~/.local/bin | grep "^-rwx"        # scripts executable
lsblk -f                                 # disk layout = disko.nix
grep -iE "qemu|virtualbox" /etc/nixos/hardware-configuration.nix   # no VM remnants
```

## Recovery

[troubleshooting.md](troubleshooting.md#recovery) → reinstall: `./install/aspire7.sh`.