# Troubleshooting

## Sops secrets fail to decrypt

Secret decryption uses the dedicated age key at `/etc/sops-nix/keys.txt`,
never the SSH host key - rotating `/etc/ssh/ssh_host_ed25519_key` does not
affect sops. If secrets fail to decrypt:

1. Check the key exists: `sudo test -f /etc/sops-nix/keys.txt`
2. Test decryption (prints nothing on success):

   ```bash
   sudo SOPS_AGE_KEY_FILE=/etc/sops-nix/keys.txt \
     nix run .#sops -- -d secrets/secrets.yaml >/dev/null
   ```

3. Restore the key from the backup (`sudo bash install/key-backup.sh decrypt`)
   or from the Bitwarden copy, then rebuild.

On a fresh host, `sops.age.generateKey` may have minted a random key that is
not an authorized recipient of existing committed secrets (chicken-and-egg):
either restore the backed-up key before activation, or run
`install/init-secrets.sh` to register the host and re-encrypt from an existing
host (`sops updatekeys --yes secrets/secrets.yaml`).

## Home Manager/dconf/Hyprland fail with permission errors

If `~/.config` or one of its subdirectories was created with `sudo`, Home
Manager may fail at `dconfSettings` with `Permission denied`, and Hyprland may
then report that it could not create its config directory. The Hyprland error
is downstream: Home Manager aborted before linking its config.

Check the ownership of every path component:

```bash
namei -l ~/.config/dconf
```

Repair the user configuration tree, then rerun Home Manager activation:

```bash
sudo chown -R "$USER":users "$HOME/.config"
sudo systemctl restart "home-manager-$USER.service"
```

Do not launch Hyprland from `sudo -i`; that root shell has no normal logind
session and therefore no `XDG_RUNTIME_DIR`. This is separate from ownership
errors.

Prevention: never use `sudo mkdir`, `sudo touch`, `sudo cp`, or similar for a
path under a regular user's home. This configuration declares `~/.config`,
`~/.config/dconf`, and the root-managed secret directories through
systemd-tmpfiles with user ownership. A required pre-Home-Manager service also
repairs wrongly owned entries anywhere below `~/.config` before each activation.

## Home Manager: "Existing file ... would be clobbered"

Converting an app from raw `xdg.configFile` (e.g. a whole-dir
`xdg.configFile."<app>"`) to a native module leaves a stale symlink at
`~/.config/<app>` pointing at the previous generation's store path. On the next
switch, home-manager refuses to overwrite it once:

```text
Existing file '/home/<user>/.config/<app>/config' would be clobbered
Failed to start Home Manager environment for <user>.
```

Fix; remove the stale symlink (user-owned, no sudo), then rebuild:

```bash
rm ~/.config/<app>
./install/rebuild.sh
```

The next generation owns the path, so it only happens on the conversion
switch. To make home-manager overwrite instead, add `force = true` to the file
option (e.g. `xdg.configFile."<app>/config".force = true`).

## Rollback

Backups are NixOS generations (ext4 root, no snapshots).

- Older generation: pick from systemd-boot menu
- System + home: `sudo nixos-rebuild switch --rollback`
- Home only: `nix profile rollback --profile /nix/var/nix/profiles/per-user/$USER`
- Keep history: `nix-collect-garbage --delete-older-than 30d`

## Recovery

Won't boot, no generation helps → USB installer ISO:

```bash
lsblk -f                                                   # find partitions
mount /dev/disk/by-id/<root-part> /mnt                     # see hosts/<host>/disko.nix
mount /dev/disk/by-id/<boot-part> /mnt/boot
nixos-enter --root /mnt                                    # enter installed system
git clone <repo-url> /tmp/nixos-dots && cd /tmp/nixos-dots
nixos-rebuild switch --flake .#<host>
```

Disk dead → reinstall: `./install/install.sh <host>` (wipes, via nixos-anywhere). Per-host: [Aspire 7](aspire7.md).

Daily ops: [maintenance.md](maintenance.md).