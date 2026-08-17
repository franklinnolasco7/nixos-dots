# Installation

`install/install.sh` drives the whole install via nixos-anywhere:

- **Wipes the entire disk.** Disko runs in `destroy,format,mount` mode on the
  device from `hosts/<host>/disko.nix` (all hosts share the GPT layout in
  `modules/disko/gpt-layout.nix`: 1 GiB ESP + LUKS root at 100% of the disk).
  Every existing partition is destroyed: other operating systems and their
  bootloaders, stray LUKS or swap partitions, the old ESP. No manual partition
  cleanup is needed, and nothing on the disk survives. The machine ends up
  single-boot NixOS by design.
- **Restores the SSH host key** from the repo's encrypted backup, so sops
  secrets stay readable on the new system.
- **Does not reboot.** The installer finishes with the disk mounted; you
  reboot manually.

> [!WARNING]
> The wipe is the whole point: every partition on the target disk is
> destroyed, including other operating systems. Move anything worth keeping
> off the disk first; there is no undo.

## Prerequisites

- Internet, and a machine with Nix that can reach the target over SSH. The
  target machine itself works (see "On an existing NixOS machine").
- Backed-up keys on the current system (see [secrets.md](secrets.md):
  `sudo bash install/key-backup.sh encrypt`). The installer aborts the wipe
  unless the backup is found and decrypts `secrets/secrets.yaml`.

### Source machine

Any **x86_64 Linux** with Nix works as the source, not just NixOS (Arch,
Debian, Fedora, ...):

- Nix with flakes: `sudo pacman -S nix` + `sudo systemctl enable --now
  nix-daemon` on Arch, the Determinate nix-installer elsewhere. The installer
  enables flakes per-invocation (`--experimental-features "nix-command flakes"`),
  so no `nix.conf` edits are needed.
- `bash`, `git`, `ssh`; `sshpass` when installing with a password.
- ~20-30 GiB free on the source: the full desktop closure builds there before
  it is copied to the target.
- The `--target <user>@localhost` self-install additionally needs sshd running
  on the source (nixos-anywhere reaches the target over SSH even when it *is*
  the source) and passwordless sudo for the target user. A NixOS source
  already runs sshd; other distros need it enabled.

## Install

The installer builds the system closure on the machine that runs
`install.sh`, then copies it to the target. The NixOS minimal ISO's nix store
is RAM-backed and cannot hold a desktop-profile closure, so the ISO is a
recovery and rehearsal medium, not the install medium.

### On an existing NixOS machine (recommended)

The build reuses the store already on the disk (incremental), then kexecs
into the installer and wipes the disk from there.

```bash
# nixos-anywhere needs passwordless sudo for a non-root target user
echo '<user> ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/99-nixos-anywhere
sudo visudo -c

# SSHPASS skips the interactive ssh-copy-id; omit the env var and flag to type it
SSHPASS='<login password>' ./install/install.sh <host> --target <user>@localhost --env-password
```

> [!NOTE]
> The NOPASSWD drop-in is temporary by construction: the wipe destroys the
> disk it lives on, so nothing needs to be cleaned up afterwards.

Prompts, in order: the age backup passphrase, `yes` to confirm the wipe, and
the new LUKS disk passphrase (twice, then again at every boot). The machine
goes briefly offline during the kexec handover and reconnects on its own.
Then:

```bash
reboot
```

### Remote target over SSH

Any machine with Nix and SSH access can install any host:

```bash
./install/install.sh <host> --target root@<ip>
```

A target with no OS yet: boot the minimal ISO on it (USB or netboot), set a
password (`passwd`), then install from here with `--target nixos@<iso-ip>` —
nixos-anywhere detects the installer and skips the kexec step.

Use `--minimal` for the console-TTY variant (no display server). The `-min`
suffix is reserved for profile variants of an existing host; it is never a
real hostname.

## Post-install

Commit the regenerated hardware config (mounts come from disko, so it is
UUID-free):

```bash
git add hosts/<host>/hardware-configuration.nix && git commit
```

- LUKS hosts: back up the disk header off-machine while it is healthy; it is
  the only way to unlock the root after a lost or corrupt header:

> [!IMPORTANT]
> `sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-main-root --header-backup-file <off-machine-path>`
- The user's password is the sops-managed `user-password-hash` in
  `secrets/secrets.yaml`; change it there and rebuild.

## New host

1. Run `nixos-generate-config` on the target and copy the result into
   `hosts/<host>/`
2. Write `hosts/<host>/disko.nix` for the disk layout (pin the real device
   path; see the existing host entries for the pattern)
3. Wire `hosts/<host>/` into `flake.nix`: `mkSystem` with `useDiskoMounts =
   true` plus a `mkDisko` entry (see the existing host entries)
4. The declared user needs a `users/<user>/` home-manager config
5. First install (nothing to back up): pregenerate a key, skip the sops
   check, then install as above:
   ```bash
   ssh-keygen -t ed25519 -N "" -f /tmp/newhost-key/ssh_host_ed25519_key
   SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key \
     ./install/install.sh <host> --target root@<ip>
   ```
   After boot: `bash install/init-secrets.sh`, update `.sops.yaml` recipients
   from an existing host, then create the first backup with
   `sudo bash install/key-backup.sh encrypt`.

## Rehearsal

`./install/run-vm.sh /path/to/nixos-minimal.iso` runs the exact installer
flow (disko wipe, key restore, install) against a throwaway QEMU disk, VM ssh
on host port 2222. From the repo on the host:

```bash
mkdir -p /tmp/ssh-host-key-backup
ssh-keygen -t ed25519 -N "" -f /tmp/ssh-host-key-backup/ssh_host_ed25519_key
SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/ssh-host-key-backup \
  ./install/install.sh vm --target nixos@localhost --ssh-port 2222
./install/run-vm.sh   # boot the installed VM (no ISO)
```

The VM shares the LUKS layout with the physical host, so the passphrase prompt
doubles as an unlock check.

> [!CAUTION]
> Never `nixos-rebuild switch --flake .#vm` on a real host; the fstab would
> point at VM-only partlabels.

## Recovery

Boot the minimal ISO from USB, unlock and mount the LUKS root, and enter the
installed system with `nixos-enter`; see [troubleshooting.md](troubleshooting.md).

Per-host details: [Aspire 7](aspire7.md). Daily ops: [maintenance.md](maintenance.md).