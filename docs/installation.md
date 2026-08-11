# Installation

## Prerequisites

NixOS Minimal ISO, internet.

## Install

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots

sudo ./install/install.sh <hostname>   # Disko wipe + nixos-install
sudo reboot
```

> [!IMPORTANT]
> Wipes the target disk.

## Post-Install

```bash
cd nixos-dots
./install/init-secrets.sh   # first verify /etc/ssh/ssh_host_ed25519_key exists
```

Secrets afterward: [secrets.md](secrets.md).

## New Host

1. `nixos-generate-config --root /mnt`
2. Copy hardware config into `hosts/<hostname>/`
3. Add `disko.nix` for the disk layout
4. Wire into `flake.nix`
5. Install: `sudo ./install/install.sh <hostname>`

Per-host: [Aspire 7](aspire7.md). Daily ops: [maintenance.md](maintenance.md).