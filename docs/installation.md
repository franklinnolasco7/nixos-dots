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

Boot the NixOS Minimal ISO on the target machine (or `./install/run-vm.sh
<iso>` to rehearse in a VM — see below). **On the ISO console**:

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots
sudo passwd     # set a password for root — nixos-anywhere's one-time ssh-copy-id uses it
```

Then run the installer. From the repo **on the ISO** this is a self-install;
from any other Nix machine it installs a remote target over SSH:

```bash
sudo HOST_KEY_SRC=<usb-backup-dir> ./install/install.sh <hostname>          # self-install on the ISO
HOST_KEY_SRC=<usb-backup-dir> ./install/install.sh <hostname> --target nixos@<ip>   # remote ISO over SSH
sudo reboot   # after a self-install; for a remote target, reboot it directly
```

`HOST_KEY_SRC` defaults to `/root/ssh-host-key-backup`. The installer
**refuses to start without a verified key backup**, verifies that the backup
host key can decrypt `secrets/secrets.yaml` (so the wipe can't lock you out of
your secrets), and asks you to type `yes` to confirm the wipe. Then it runs
**nixos-anywhere** (pinned via the flake: `nix run .#nixos-anywhere -- ...`)
with the `disko,install` phases:

1. Wipes and repartitions the disk from `hosts/<hostname>/disko.nix`, mounting
   the new layout at `/mnt`. No reboot phase — `/mnt` stays mounted.
2. Regenerates `hosts/<hostname>/hardware-configuration.nix` **without
   filesystems** (`--no-filesystems`): `fileSystems`/`swapDevices` come from
   `disko.nix` at build time, so the committed file is **UUID-free** and never
   needs churning after a reinstall.
3. Restores the backed-up SSH host key via `--extra-files` (into the new
   system's `/etc/ssh/`) so sops can decrypt during activation.
4. Installs the system (`nixos-install`).
5. Writes `safe.directory` for root on the new system (no `nixos-rebuild`
   ownership friction later).

SSH access: nixos-anywhere generates a throwaway key and `ssh-copy-id`s it to
the ISO, prompting once for the password you set with `sudo passwd`. All extra
arguments (e.g. `--ssh-port 2222`, `-i <key>`) are passed through to
nixos-anywhere unchanged.

> [!IMPORTANT]
> Wipes the target disk.

## Post-Install

```bash
cd nixos-dots

git add hosts/<hostname>/hardware-configuration.nix && git commit   # UUID-free — nothing to churn
./install/init-secrets.sh                                            # register new host in .sops.yaml
```

The user's password is declarative (no `passwd`): it's the sops-managed hash
`user-password-hash` in `secrets/secrets.yaml` (see [secrets.md](secrets.md)).
Change it by updating the hash there and rebuilding. Throwaway hosts without
sops (the rehearsal `vm`) use a fixed `initialPassword`.

Secrets afterward: [secrets.md](secrets.md).

## WireGuard VPN (manual)

The Proton profile stays out of the flake — `wg0.conf` is personal.

1. Get `wg0.conf` from Proton (VPN → WireGuard configuration → generate keys).
2. Install it:
   ```bash
   sudo mkdir -p /etc/wireguard
   sudo cp wg0.conf /etc/wireguard/wg0.conf
   sudo chmod 600 /etc/wireguard/wg0.conf
   ```
   > [!IMPORTANT]
   > `DNS = <proton-dns>` is **required** in `wg0.conf` (e.g. `10.2.0.2` for
   > Proton). wg-quick pushes DNS through the resolver only when the `DNS`
   > key is present — without it the tunnel comes up but resolution leaks to
   > the clearnet.
3. Toggle with `vpn-toggle` (a toggle button in the swaync control center,
   `modules/home/wayland/swaync/default.nix`):
   ```bash
   vpn-toggle            # toggle connect/disconnect
   vpn-toggle status     # prints true/false (feeds the swaync toggle state)
   ```

   DNS goes through systemd-resolved (`services.resolved.enable` +
   `networking.networkmanager.dns = "systemd-resolved"`), and
   `vpn-toggle` clears a stale `/run/resolvconf/lock` before each
   `wg-quick` run so the DNS hook can't hang.

## New Host

1. `nixos-generate-config --root /mnt` (or let nixos-anywhere generate the
   `hardware-configuration.nix` with `--generate-hardware-config` on install)
2. Copy hardware config into `hosts/<hostname>/`
3. Add `disko.nix` for the disk layout (sets `device` + partitions) — it is
   imported automatically by `mkSystem`, so it also supplies
   `fileSystems`/`swapDevices` at build time
4. Wire into `flake.nix` — one line per config:
   ```nix
   nixosConfigurations.<hostname> = mkSystem { hostDir = ./hosts/<hostname>; user = "frank"; };
   diskoConfigurations.<hostname> = mkDisko ./hosts/<hostname>;
   ```
5. The declared user needs a `users/<user>/` home-manager config (`import ./users/${user}/default.nix` fails if missing)
6. Install (backup keys first): `sudo ./install/install.sh <hostname>`

Per-host: [Aspire 7](aspire7.md). Daily ops: [maintenance.md](maintenance.md).

## Rehearse in a VM

Run the exact installer flow (nixos-anywhere: disko wipe → UUID-free hw-config
regen → host-key restore via `--extra-files` → `nixos-install`) against a
throwaway virtio disk, **without touching real hardware**. The `vm` host
(`hosts/vm/`) uses the same GPT layout as the Aspire 7 but targets `/dev/vda`
and skips host-specific modules (nvidia, acer-battery, sops).

```bash
./install/run-vm.sh /path/to/nixos-minimal.iso      # QEMU/KVM + UEFI (OVMF), 40G disk; VM ssh on host port 2222
# in the VM console:
sudo passwd                                          # root password for nixos-anywhere's ssh-copy-id
# on the host (repo already cloned):
mkdir -p /tmp/ssh-host-key-backup
ssh-keygen -t ed25519 -N "" -f /tmp/ssh-host-key-backup/ssh_host_ed25519_key
SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/ssh-host-key-backup \
  ./install/install.sh vm --target nixos@localhost --ssh-port 2222
# back on the host — boot the installed VM (no ISO):
./install/run-vm.sh
```

> [!NOTE]
> The VM must boot with UEFI/OVMF (`ls /sys/firmware/efi` non-empty) —
> systemd-boot requires it. No USB in the VM, so a freshly generated host key
> satisfies the backup gate (sops is not active for the `vm` host anyway);
> `SKIP_SOPS_CHECK=1` skips the sops pre-check, which a throwaway key cannot
> pass.
