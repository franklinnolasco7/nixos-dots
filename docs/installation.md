# Installation

`install/install.sh` drives the whole install via nixos-anywhere. It wipes
the entire disk: disko runs in `destroy,format,mount` mode on the device from
`hosts/<host>/disko.nix` (all hosts share the GPT layout in
`modules/disko/gpt-layout.nix`: 1 GiB ESP + LUKS persist partition at 100% of
the disk, mounted at `/nix`; `/` is a tmpfs). Every existing partition is
destroyed: other operating systems and their bootloaders, stray LUKS or swap
partitions, the old ESP. No manual partition cleanup is needed, and nothing
on the disk survives. The machine ends up single-boot NixOS.

It also restores the dedicated sops age key and the SSH host key from the
repo's encrypted backup, so sops secrets stay readable on the new system.
Because `/` is tmpfs, install.sh stages these into `nix/persist/...` on the
target; impermanence bind-mounts them back to `/etc` on first boot.

It does not reboot. The installer finishes with the disk mounted; you reboot
manually.

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
- Wired Ethernet on the target for the install window: the kexec handover
  drops Wi-Fi, and nixos-anywhere cannot use it (upstream limitation).
- The disk wipe destroys the repo working copy: `git push` first.

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

## Pre-flight runbook

Run these before any install; nothing here is destructive yet:

1. The SSH key must be in the agent (signed commits and the installer's SSH
   auth both go through it):
   ```bash
   ssh-add -l        # should list id_ed25519; if not: ssh-add
   ```
2. Repo committed and pushed, since the wipe destroys the working copy:
   ```bash
   git status --short      # must be empty
   git push
   ```
3. Back up the keys. This is the installer's abort-gate: it refuses to wipe
   unless a decodable backup exists:
   ```bash
   sudo bash install/key-backup.sh encrypt
   ```
   - Prompts: age passphrase (type it and confirm, then save it; it is the
     single secret).
   - Verify: `ls secrets/key-backup-<hostname>.tar.age`, and `git status`
     shows the new blob (the script commits + pushes it). On a reinstall,
     rerunning encrypt refreshes it in place.
   - Failure fallback: if the script errors (git identity, push), fix and
     rerun. Do not proceed to the wipe.
4. Passwordless sudo for nixos-anywhere. Temporary: the wipe
   destroys the drop-in it writes, so nothing needs cleanup afterwards:
   ```bash
   echo '<user> ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/99-nixos-anywhere
   sudo visudo -c            # must print "parsed OK"
   ```
5. Temporary root SSH for the kexec handover. nixos-anywhere uploads its
   installer key to `root@localhost`, but this repo's hosts harden root login
   away (`PermitRootLogin = "no"`), so the wipe fails at the key upload. On
   NixOS, `/etc/ssh/sshd_config` is a read-only symlink to the Nix store, so
   drop-in files in `/etc/ssh/sshd_config.d/` are ignored (the generated
   config has no `Include` line). The only way to change it is through the
   NixOS module. Temporarily allow key-only root login; the wipe destroys
   the change with the disk:
   ```bash
   # In modules/nixos/system/hardening.nix, change:
   #   PermitRootLogin = "no";
   # To:
   #   PermitRootLogin = "prohibit-password";
   sudo nixos-rebuild switch
   sudo mkdir -p /root/.ssh
   sudo cp ~/.ssh/id_ed25519.pub /root/.ssh/authorized_keys
   sudo sshd -T | grep -i permitrootlogin   # must say prohibit-password
   ssh root@localhost 'echo root-ssh-ok'     # verify before continuing
   ```
6. Wired Ethernet on the install window: the kexec handover drops Wi-Fi, and
   nixos-anywhere cannot use it.
7. Optional sanity: `nix flake check` (catches a broken flake before the
   long build).

> [!IMPORTANT]
> Nothing is wiped until the installer's `yes` prompt; abort there if any
> step above failed or is unverified.

> [!CAUTION]
> Never run `sudo mkdir`, `sudo touch`, `sudo cp`, or similar commands against
> paths inside a regular user's home. For example, do **not** run
> `sudo mkdir -p ~/.config/dconf`: if a parent is missing, root creates it as
> `root:root`, which can break dconf, abort Home Manager activation, and leave
> Hyprland without a usable config. Run home-directory commands as that user;
> reserve `sudo` for system paths such as `/etc` and `/root`.

## Install

The installer builds the system closure on the machine that runs
`install.sh`, then copies it to the target. The NixOS minimal ISO is a
recovery and rehearsal medium, not the install medium. The manual ISO path
in the next section is the exception and builds on the target itself.

### On an existing NixOS machine (recommended)

The build reuses the store already on the disk (incremental), then kexecs
into the installer and wipes the disk from there. Pre-flight steps 3 and 4
(key backup, passwordless sudo) apply here too.

```bash
# SSHPASS skips the interactive ssh-copy-id; omit the env var and flag to type it
SSHPASS='<login password>' ./install/install.sh <host> --target <user>@localhost --env-password
```

> [!TIP]
> `SSHPASS`/`--env-password` is the password-auth form, used by the rehearsal
> VM. This repo's hosts run key-only sshd: the command form is
> `./install/install.sh <host> --target <user>@localhost`, with the key in
> the agent (`ssh-add -l`; load it once per login, since the persistent agent
> does not auto-load keys). `nix flake check` is a cheap pre-flight that catches a
> broken flake before the long build.

Prompts: the age backup passphrase, `yes` to confirm the wipe, and
the new LUKS disk passphrase (twice, then again at every boot). The machine
goes briefly offline during the kexec handover and reconnects on its own.

After installation, `install.sh` finds the single normal user declared by the
flake (`frank`) and runs `passwd` on the mounted target. Enter and confirm the
new login password at that prompt, then reboot:

```bash
reboot
```

The username remains declarative in `flake.nix`; the installer does not ask for
or modify it. It aborts if a configuration declares zero or multiple normal
users instead of guessing which account should receive the password.

A direct `nixos-install --flake .#aspire7-min` bypasses the installer prompt.
For that path, `frank` is created with the bootstrap password `123`; after the
first local login, immediately run `passwd`. Password authentication over SSH
is disabled, but the bootstrap password should still be changed promptly.

### Remote target over SSH

Any machine with Nix and SSH access can install any host:

```bash
./install/install.sh <host> --target root@<ip>
```

A target with no OS yet: boot the minimal ISO on it (USB or netboot), set a
password (`passwd`), then install from here with `--target nixos@<iso-ip>`.
nixos-anywhere detects the installer and skips the kexec step.

Use `--minimal` for the console-TTY variant (no display server). The `-min`
suffix is reserved for profile variants of an existing host; it is never a
real hostname.

## Manual install from the minimal ISO (no nixos-anywhere)

Use this path when the target only has Wi-Fi. nixos-anywhere's kexec handover
drops the wireless link (an upstream limitation), but the live ISO keeps its
full network stack, so `nmtui` Wi-Fi covers the whole install.

> [!NOTE]
> `iso-install.sh` installs the minimal profile by default. Pass `--full` to
> install the full desktop directly. Phase 2 shows both.

### Pre-flight

```bash
cd ~/nixos-dots
git add -A && git commit -m "chore: pre-install sync" || true
git push
```

### Phase 1: Boot NixOS ISO

1. Plug in Ethernet or have Wi-Fi ready (this path supports both).
2. Boot from the NixOS USB (`F12` → select USB), log in as `nixos`.

### Phase 2: Install (minimal or full)

Set a password on the ISO user and connect to the network:

```bash
passwd
nmtui        # activate Wi-Fi (Ethernet needs nothing)
ping -c1 1.1.1.1
```

Clone the repo:

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots
```

Run the ISO installer as root. It bootstraps the flake's build caches into root's
nix config, wipes the disk with disko, and generates the hardware config. Then
it installs the system and copies the sops age key, SSH host key, and root's
gitconfig into `/nix/persist` (impermanence bind-mounts them at boot):

```bash
sudo ./install/iso-install.sh          # minimal profile (.#<host>-min)
sudo ./install/iso-install.sh --full   # full desktop directly
```

Prompts: the age backup passphrase, `yes` to confirm the wipe, and the new
LUKS disk passphrase (twice, then again at every boot).

Reboot (remove the USB when the screen goes black):

```bash
sudo reboot
```

### Phase 3: Switch to full desktop (minimal installs only)

Skip this phase if you installed with `--full` in Phase 2. You're already on
the full desktop. Go straight to [Phase 4](#phase-4-verify).

1. Type the LUKS passphrase at boot; log in as `frank` (bootstrap password
   `123`).

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots
git add hosts/aspire7/hardware-configuration.nix && git commit -m "chore: regenerate hardware config"
bash install/key-backup.sh decrypt   # restore user ssh + age keys
sudo nixos-rebuild switch --flake .#aspire7   # full profile (no -min suffix)
```

The `.#aspire7` flake attr (no `-min` suffix) moves you from the minimal
profile to the full desktop.

After the switch completes:

```bash
reboot
```

### Phase 4: Verify

```bash
hostname
nvidia-smi
nix eval --raw '.#nixosConfigurations.aspire7.config.myProfile'
ls ~/.config/opencode/context7-key
```

> [!NOTE]
> This path handles post-install in Phase 3 (clone, restore user keys, commit
> the hardware config). The `## Post-install` section below is for the
> nixos-anywhere flow and repeats those steps.

## Post-install

The wipe destroyed the repo, so clone it back first (signed commits need the
SSH key in the agent):

```bash
git clone https://github.com/franklinnolasco7/nixos-dots.git
cd nixos-dots
```

Restore the personal user keys before the first signed commit (SSH client /
git-signing key and sops user keys; the installer's passphrase prompt restored
only the dedicated sops age key and the SSH host key):

```bash
bash install/key-backup.sh decrypt
```

- Never run it with `sudo`; the keys land in `/root` instead of the user's
  home.
- If the boot-time key hook already generated a throwaway `~/.ssh/id_ed25519`,
  answer `y` to the overwrite prompt.
- Verify afterwards: `ssh-keygen -lf ~/.ssh/id_ed25519.pub` must match your
  GitHub signing key.

Then commit the regenerated hardware config (mounts come from disko, so it is
UUID-free):

```bash
git add hosts/<host>/hardware-configuration.nix && git commit
```

Per-host checklist and LUKS header backup: [aspire7.md](aspire7.md).

- LUKS hosts: back up the disk header off-machine while it is healthy; it is
  the only way to unlock the persist partition after a lost or corrupt header:

> [!IMPORTANT]
> `sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-main-persist --header-backup-file <off-machine-path>`
- Nix provides only the fresh-install bootstrap password `123`. Login
  passwords are otherwise mutable and not managed by sops; later `passwd`
  changes are preserved by rebuilds.

## New host

1. Run `nixos-generate-config` on the target and copy the result into
   `hosts/<host>/`
2. Write `hosts/<host>/disko.nix` for the disk layout (pin the real device
   path; see the existing host entries for the pattern)
3. Wire `hosts/<host>/` into `flake.nix`: `mkSystem` with `useDiskoMounts =
   true` plus a `mkDisko` entry (see the existing host entries)
4. The declared user needs a `users/<user>/` home-manager config
5. First install (nothing to back up): pregenerate the dedicated sops age
   key, skip the sops check, then install as above:
   ```bash
   mkdir -p /tmp/newhost-key
   nix shell nixpkgs#age -c age-keygen -o /tmp/newhost-key/sops-age-key.txt
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
mkdir -p /tmp/sops-age-key-backup
nix shell nixpkgs#age -c age-keygen -o /tmp/sops-age-key-backup/sops-age-key.txt
SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/sops-age-key-backup \
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