# Aspire 7

Host config: `hosts/aspire7/`.

## Hardware

| Component | Detail |
|---|---|
| Disk | SK hynix ~512GB NVMe, by-id: `nvme-HFM512GD3JX016N_FYB3N036910803I0I` (verified, not `/dev/nvme0n1`) |
| GPU | NVIDIA PRIME offload: amdgpu `PCI:5:0:0`, nvidia `PCI:1:0:0` |
| Battery | Acer kernel module (`acer-battery.nix`) |
| Layout | tmpfs `/` (4G) + 1G `/boot` vfat + LUKS-encrypted ext4 `/nix` (persist + store; swap via zramSwap) |

> [!WARNING]
> Verify by-id path with `lsblk -f` before destructive Disko runs.

## Install

Wipes the whole disk; see [installation.md](installation.md) for the flow and
why the minimal ISO is not the install medium. Needs, before you start: wired
Ethernet for the install window, the repo pushed to GitHub (the disk is
wiped), and the SSH key in the agent. Backup first, then install:

```bash
sudo bash install/key-backup.sh encrypt   # age-passphrase backup → commits + pushes the blob
./install/aspire7.sh --target <user>@localhost   # wipe + install; prompts for frank's password
reboot
```

Wi-Fi only? Use the manual ISO path instead: install minimal from the ISO,
then switch to full on first boot. See
[installation.md](installation.md#manual-install-from-the-minimal-iso-no-nixos-anywhere).

The target user needs passwordless sudo (one `sudoers.d` line; see
installation.md). sshd here is key-only, so the agent key authenticates and
`--env-password` is neither needed nor accepted.

`install/key-backup.sh encrypt` packs the dedicated sops age key, the host
SSH key, the user age key, and `~/.ssh/id_ed25519` into
`secrets/key-backup-<hostname>.tar.age` under an age passphrase and commits +
pushes it. The installer decrypts the blob automatically before wiping
(details: [secrets.md](secrets.md)). Keep the passphrase in a password
manager; also export `/etc/sops-nix/keys.txt` to Bitwarden - it is an
independent recovery artifact.

The installer aborts unless that backup exists and asks you to type `yes`
before wiping the disk. Near the end it prompts for `frank`'s permanent login
password, replacing the fresh-install bootstrap password `123`. It then runs
nixos-anywhere from the flake (phases
`disko,install`), regenerating a **UUID-free** `hardware-configuration.nix`
(filesystems come from `disko.nix` at build time) and restoring the dedicated
sops age key and SSH host key into the new system via `--extra-files`. Since
`/` is tmpfs, those keys are staged under `nix/persist/...` and bind-mounted
back to `/etc` on first boot by impermanence.

The disko phase prompts for the LUKS passphrase (twice to format, once to
mount). The same passphrase is asked at every boot to unlock the persist disk.

`./install/aspire7.sh` is a thin wrapper around the generic
`./install/install.sh aspire7`.

Post-install (SSH key, secrets, commit regenerated hardware config):
[installation.md](installation.md#post-install).

Back up the LUKS header off-machine while the disk is healthy; it is the only
way to unlock the persist disk if the header (or disk) is ever lost or corrupted:

```bash
sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-main-persist \
  --header-backup-file <off-machine-path>/luks-header.bin
```

## Checklist (fresh install)

```bash
wallpaper --dry-run | head                  # wallpaper picker finds themes/wallpapers
ls ~/.icons                              # cursor theme
fc-list | grep -iE "jetbrains|noto"      # fonts
ls ~/.config/hypr ~/.config/waybar       # app configs
which airplane-mode vpn-toggle toggle-laptop-kb  # scripts on PATH
lsblk -f                                 # disk layout = disko.nix (persist under luks-persist)
lsblk -o NAME,TYPE | grep -i luks        # persist is LUKS-encrypted
findmnt /                                # / is tmpfs
findmnt /nix                             # /nix is ext4 on luks-persist
ls -l ~/.config/opencode/context7-key    # sops secrets decrypted
sudo SOPS_AGE_KEY_FILE=/etc/sops-nix/keys.txt \
  nix run .#sops -- -d secrets/secrets.yaml >/dev/null   # real decryption test, prints nothing
grep -iE "qemu|virtualbox" /etc/nixos/hardware-configuration.nix   # no VM remnants
```

## Recovery

[troubleshooting.md](troubleshooting.md#recovery) → reinstall: `./install/aspire7.sh`.