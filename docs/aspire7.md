# Aspire 7

Host config: `hosts/aspire7/`.

## Hardware

| Component | Detail |
|---|---|
| Disk | SK hynix ~512GB NVMe, by-id: `nvme-HFM512GD3JX016N_FYB3N036910803I0I` (verified, not `/dev/nvme0n1`) |
| GPU | NVIDIA PRIME offload: amdgpu `PCI:5:0:0`, nvidia `PCI:1:0:0` |
| Battery | Acer kernel module (`acer-battery.nix`) |
| Layout | GPT: 1G `/boot` vfat + LUKS-encrypted ext4 root (swap via zramSwap) |

> [!WARNING]
> Verify by-id path with `lsblk -f` before destructive Disko runs.

## Install

```bash
sudo bash install/backup-host-key.sh   # detects USB drives and prompts (sops identities)
sudo HOST_KEY_SRC=<backup-dir> ./install/aspire7.sh # nixos-anywhere wipe + install
sudo reboot
```

`install/backup-host-key.sh` with no argument scans for removable drives
(`lsblk RM=1`), picks the **largest** usable partition (skips Ventoy's
`VTOYEFI`/EFI partitions), mounts it if needed, and saves the backup to
`<mount>/ssh-host-key-backup`. Passed a dir explicitly (`<dest-dir>`), it
saves to `<dest-dir>/ssh-host-key-backup` — or, if the arg already ends in
`ssh-host-key-backup`, straight into it. Either way it prints the path —
pass it as `HOST_KEY_SRC`.

The installer aborts unless that backup exists and asks you to type `yes`
before wiping the disk. It then runs nixos-anywhere from the flake (phases
`disko,install`), regenerating a **UUID-free** `hardware-configuration.nix`
(filesystems come from `disko.nix` at build time) and restoring the SSH host
key into the new system via `--extra-files`.

The disko phase prompts for the LUKS passphrase (twice to format, once to
mount). The same passphrase is asked at every boot to unlock the root disk.

`./install/aspire7.sh` is a thin wrapper around the generic
`./install/install.sh aspire7`.

Post-install (SSH key, secrets, commit regenerated hardware config):
[installation.md](installation.md#post-install).

Back up the LUKS header off-machine while the disk is healthy — it is the only
way to unlock the root disk if the header (or disk) is ever lost or corrupted:

```bash
sudo cryptsetup luksHeaderBackup /dev/disk/by-partlabel/disk-main-root \
  --header-backup-file <off-machine-path>/luks-header.bin
```

## Checklist (fresh install)

```bash
wallpaper --dry-run | head                  # wallpaper picker finds themes/wallpapers
ls ~/.icons                              # cursor theme
fc-list | grep -iE "jetbrains|noto"      # fonts
ls ~/.config/hypr ~/.config/waybar       # app configs
which airplane-mode vpn-toggle toggle-laptop-kb  # scripts on PATH
lsblk -f                                 # disk layout = disko.nix (root under luks-root)
lsblk -o NAME,TYPE | grep -i luks        # root is LUKS-encrypted
ls -l ~/.config/opencode/context7-key    # sops secrets decrypted
grep -iE "qemu|virtualbox" /etc/nixos/hardware-configuration.nix   # no VM remnants
```

## Recovery

[troubleshooting.md](troubleshooting.md#recovery) → reinstall: `./install/aspire7.sh`.