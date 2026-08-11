# Installation

## Prerequisites

NixOS Minimal ISO, internet.

> [!WARNING]
> Before wiping, back up the sops decryption identities — a fresh install
> regenerates the SSH host key, making committed secrets unreadable:

```bash
sudo bash install/backup-host-key.sh              # detects USB drives and prompts
sudo bash install/backup-host-key.sh <dest-dir>   # or save to an explicit dir
```

## Install

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots

sudo HOST_KEY_SRC=<usb-backup-dir> ./install/install.sh <hostname>   # Disko wipe + nixos-install
sudo reboot
```

`HOST_KEY_SRC` defaults to `/root/ssh-host-key-backup`. The installer
**refuses to start without a verified key backup** and asks you to type `yes`
to confirm the wipe. Then it:

1. Wipes and partitions the disk (Disko, pinned via the flake).
2. Regenerates `hosts/<hostname>/hardware-configuration.nix` from the **new**
   partitions — the committed copy pins the old disk's UUIDs, so it must be
   refreshed or the system won't boot.
3. Restores the backed-up SSH host key so sops can decrypt during activation.
4. Runs `nixos-install --flake .#<hostname>`.

> [!IMPORTANT]
> Wipes the target disk.

## Post-Install

```bash
cd nixos-dots

git add hosts/<hostname>/hardware-configuration.nix && git commit   # new UUIDs
passwd frank                                                         # was "changeme"
./install/init-secrets.sh                                            # register new host in .sops.yaml
```

Secrets afterward: [secrets.md](secrets.md).

## New Host

1. `nixos-generate-config --root /mnt`
2. Copy hardware config into `hosts/<hostname>/`
3. Add `disko.nix` for the disk layout (sets `device` + partitions)
4. Wire into `flake.nix` — one line per config:
   ```nix
   nixosConfigurations.<hostname> = mkSystem { hostDir = ./hosts/<hostname>; user = "frank"; };
   diskoConfigurations.<hostname> = mkDisko ./hosts/<hostname>;
   ```
5. The declared user needs a `users/<user>/` home-manager config (`import ./users/${user}/default.nix` fails if missing)
6. Install (backup keys first): `sudo ./install/install.sh <hostname>`

Per-host: [Aspire 7](aspire7.md). Daily ops: [maintenance.md](maintenance.md).