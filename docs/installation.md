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

# Run installer for a target host
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

Ongoing secrets work (edit/add/re-encrypt): [secrets.md](secrets.md).

## 3. Adding a New Host

1. Boot the installer and generate hardware config: `nixos-generate-config --root /mnt`
2. Copy the generated `hardware-configuration.nix` into `hosts/<hostname>/`
3. Add a `disko.nix` matching the target disk layout
4. Wire it into `flake.nix` (`nixosConfigurations.<hostname>` + `diskoConfigurations.<hostname>`)
5. Install with `sudo ./install/install.sh <hostname>`

Per-host guides: [Aspire 7](aspire7.md)

## Day-to-Day

Rebuild, update, format, and pre-rebuild validation: [maintenance.md](maintenance.md).