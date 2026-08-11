# Aspire 7

Host-specific guide for the physical Aspire 7 (`hosts/aspire7/`).

## Hardware

| Component | Detail |
|---|---|
| Disk | SK hynix HFM512GD3JX016N, ~512 GB NVMe (`/dev/disk/by-id/nvme-HFM512GD3JX016N_FYB3N036910803I0I` — verified, do not use `/dev/nvme0n1`) |
| GPU | NVIDIA PRIME offload (amdgpu `PCI:5:0:0`, nvidia `PCI:1:0:0`) |
| Battery | Acer battery kernel module (`acer-battery.nix`) |
| Layout | GPT: 1G `/boot` (vfat) + 8G swap + ext4 root (rest) |

> [!WARNING]
> Before any destructive Disko run, verify the by-id path still resolves to the intended disk (`lsblk -f`).

## Install

```bash
sudo ./install/aspire7.sh   # Disko wipe + nixos-install
sudo reboot
```

Post-install setup (SSH key check, secrets bootstrap): [installation.md](installation.md#2-post-installation-setup).

## Post-Install Checklist

```bash
# Wallpapers (deployed to ~/wallpapers)
ls ~/wallpapers

# Cursor theme and icon theme
ls ~/.icons
gsettings get org.gnome.desktop.interface icon-theme

# Fonts reachable by fontconfig
fc-list | grep -iE "jetbrains|noto" | head

# App configs (Hyprland, Waybar, Rofi, SwayNC, kitty, ...)
ls ~/.config/hypr ~/.config/waybar ~/.config/rofi ~/.config/swaync

# Scripts deployed AND executable
ls -l ~/.local/bin | grep "^-rwx"

# Disk layout matches disko.nix
lsblk -f

# No VM-specific hardware remnants
grep -iE "qemu|virtualbox" /etc/nixos/hardware-configuration.nix
```

## Recovery

Follow [troubleshooting.md](troubleshooting.md#recovery-broken-system); reinstall: `./install/aspire7.sh`.