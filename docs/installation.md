# Installation Guide

Step-by-step guide for installing this NixOS configuration on a new target machine.

## Prerequisites

1. Bootable USB with latest [NixOS Minimal ISO](https://nixos.org/download.html).
2. Active internet connection (WiFi via `nmcli`, `nmtui`, or Ethernet).

## 1. Disk Partitioning & Installation

Boot into the NixOS installer environment, open a terminal, and run:

```bash
# Clone repository
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots

# Run installer (default target host: aspire7)
sudo ./install/install.sh <hostname>
```

> [!IMPORTANT]
> The installer runs Disko partitioning and `nixos-install`. This will **wipe the target disk**.

Once `nixos-install` completes:

```bash
sudo reboot
```

## 2. Post-Installation Setup

After booting into your new NixOS system:

> [!WARNING]
> Verify `/etc/ssh/ssh_host_ed25519_key` exists (generated on first boot) before running `init-secrets.sh`. Sops-nix needs this key.

```bash
cd nixos-dots

# Bootstrap sops secrets (one-time setup)
./install/init-secrets.sh
```

## Maintenance Commands

- **Rebuild changes**: `./install/rebuild.sh`
- **Update packages**: `./install/update.sh`
