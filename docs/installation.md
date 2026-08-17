# Installation

## Prerequisites

NixOS Minimal ISO, internet.

## Back up the keys first (reinstall)

A fresh install regenerates the SSH host key, so committed sops secrets would
become unreadable. On the current system, from the repo:

```bash
git pull
sudo bash install/key-backup.sh encrypt
```

The script packs the host key (`/etc/ssh/ssh_host_ed25519_key{,.pub}`), the
user age key (`~/.config/sops/age/keys.txt`) and the user SSH key
(`~/.ssh/id_ed25519{,.pub}`) into `secrets/key-backup-<hostname>.tar.age` (age
passphrase mode, scrypt), commits and pushes it. The passphrase (typed twice)
is the only secret; store it in a password manager, lose it and the backup is
unrecoverable.

If the push asks for credentials (it runs as root): your GitHub username and a
personal access token as the password (`gh auth token`; classic token with
`repo` scope).

Verify before wiping:

```bash
ls secrets/key-backup-<hostname>.tar.age
git log --oneline -1   # "chore(secrets): refresh <hostname> key backup"
```

On the ISO, the installer finds the blob automatically (fallback
`key-backup-$(hostname)` for a mismatched hostname), prompts for the
passphrase, and aborts before the wipe on a wrong one.

## Install

Boot the NixOS Minimal ISO, then **on the ISO console**:

```bash
git clone <your-repo-url>
cd nixos-dots
sudo passwd   # root password; nixos-anywhere's one-time ssh-copy-id uses it
```

Run the installer. From the repo **on the ISO** this is a self-install; from
any other Nix machine it installs a remote target over SSH. Add `--minimal`
for the console-TTY variant (no display server or GUI):

```bash
sudo ./install/install.sh <hostname>                    # self-install on the ISO
./install/install.sh <hostname> --target nixos@<ip>     # remote ISO over SSH
sudo reboot
```

The `-min` suffix is reserved for profile variants of an existing host; never
a real hostname.

What the installer does:

- Refuses to start without a verified key backup; verifies the backup host key
  can decrypt `secrets/secrets.yaml` (so the wipe can't lock you out of your
  secrets) and asks you to type `yes` to confirm the wipe.
- Wipes and repartitions the disk from `hosts/<hostname>/disko.nix`. LUKS
  hosts prompt for the disk passphrase here: twice to format, once to mount;
  the same passphrase is asked again at boot.
- Regenerates `hosts/<hostname>/hardware-configuration.nix` UUID-free
  (`--no-filesystems`; the mounts come from `disko.nix` at build time).
- Restores the backed-up SSH host key into the new system, installs it, and
  writes `safe.directory` for root (no `nixos-rebuild` ownership friction).

`HOST_KEY_SRC` defaults to the repo's `secrets/` (see the backup section); a
plaintext dir (e.g. a throwaway VM key) is used as-is. Extra arguments
(`--ssh-port`, `-i <key>`, ...) pass through to nixos-anywhere unchanged.

> [!IMPORTANT]
> Wipes the target disk.

## Post-Install

```bash
cd nixos-dots
git add hosts/<hostname>/hardware-configuration.nix && git commit
./install/init-secrets.sh      # register host in .sops.yaml (see secrets.md)
```

LUKS hosts: back up the LUKS header off-machine while the disk is healthy; it
is the only way to unlock the root disk if the header is ever lost or
corrupted:

```bash
sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-main-root \
  --header-backup-file <off-machine-path>/luks-header.bin
```

The user's password is declarative: `user-password-hash` in
`secrets/secrets.yaml` (see [secrets.md](secrets.md)). Update the hash there
and rebuild; `passwd` gets overwritten on activation.

## New Host

1. `nixos-generate-config --root /mnt` (or `--generate-hardware-config` on
   install), copy the config into `hosts/<hostname>/`
2. Add `disko.nix` for the disk layout (sets `device` + partitions)
3. Wire into `flake.nix`; disko-mounted hosts must pass `useDiskoMounts =
   true` (default is off, the layout would be ignored and the system builds
   without any mounts):
   ```nix
   nixosConfigurations.<hostname> = mkSystem { hostDir = ./hosts/<hostname>; user = "frank"; useDiskoMounts = true; };
   nixosConfigurations.<hostname>-min = mkSystem { hostDir = ./hosts/<hostname>; user = "frank"; profile = "minimal"; useDiskoMounts = true; };
   diskoConfigurations.<hostname> = mkDisko ./hosts/<hostname>;
   ```
   Add the `<hostname>-min` line only for the console-TTY variant.
4. The declared user needs a `users/<user>/` home-manager config
5. Install:
   - **Reinstall**: back up first (see above), then install as usual; the
     installer decrypts the backup from `secrets/` automatically.
   - **Brand-new host** (nothing to back up): pregenerate a key on the ISO so
     the identity survives, and skip the sops pre-check (nothing is registered
     to this host yet):
     ```bash
     ssh-keygen -t ed25519 -N "" -f /tmp/newhost-key/ssh_host_ed25519_key
     SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key ./install/install.sh <hostname>
     ```
     Post-boot: `bash install/init-secrets.sh`, `sops updatekeys` on an
     existing host (see [secrets.md](secrets.md)), then create the first
     backup: `sudo bash install/key-backup.sh encrypt`.

Per-host: [Aspire 7](aspire7.md). Daily ops: [maintenance.md](maintenance.md).

## Rehearse in a VM

Runs the exact installer flow (disko wipe, host-key restore, install) against
a throwaway virtio disk, without touching real hardware:

```bash
./install/run-vm.sh /path/to/nixos-minimal.iso   # QEMU/KVM + UEFI (OVMF), 40G disk; VM ssh on host port 2222
# in the VM console:
sudo passwd                                       # root password for ssh-copy-id
# on the host (repo already cloned):
mkdir -p /tmp/ssh-host-key-backup
ssh-keygen -t ed25519 -N "" -f /tmp/ssh-host-key-backup/ssh_host_ed25519_key
SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/ssh-host-key-backup \
  ./install/install.sh vm --target nixos@localhost --ssh-port 2222
./install/run-vm.sh   # boot the installed VM (no ISO)
```

Notes:

- The `vm` host derives its mounts from the disko layout (`disk-main-*`
  partlabels). Never `nixos-rebuild switch --flake .#vm` on a real host; it
  would rewrite fstab to partlabels that don't exist there, leaving `/boot`
  unmounted. Dry `install/rebuild.sh vm build` only.
- The VM must boot with UEFI/OVMF (`ls /sys/firmware/efi` non-empty) and
  shares the LUKS layout, so the disk passphrase is prompted during the
  rehearsal too (which doubles as the unlock check).
- The rehearsal passes a throwaway plaintext key dir; no encrypted backup
  involved (`SKIP_SOPS_CHECK=1` skips the sops pre-check, which a throwaway
  key cannot pass).
