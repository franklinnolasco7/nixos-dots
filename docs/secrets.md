# Secrets

sops-nix + age with two decryption keys:

- **Host SSH key** (`/etc/ssh/ssh_host_ed25519_key`): the only identity used at
  activation (`modules/nixos/tools/sops.nix`).
- **User age key** (`~/.config/sops/age/keys.txt`): lets you edit secrets
  without `sudo`.

Encrypted data: `secrets/secrets.yaml`, encrypted to the recipients listed in
`.sops.yaml`. Safe to commit: without a key it is an opaque blob.

## Backup (before reinstalls)

```bash
sudo bash install/key-backup.sh encrypt
```

Packs the host key, the user age key and `~/.ssh/id_ed25519` into
`secrets/key-backup-<hostname>.tar.age` (age passphrase, scrypt) and commits +
pushes it. The passphrase is the only secret; keep it in a password manager,
lose it and the backup is useless. The installer decrypts the blob
automatically before the wipe; after boot, restore the optional user keys with
`bash install/key-backup.sh decrypt`.

## Bootstrap (first host)

```bash
bash install/init-secrets.sh
```

Registers the host (age recipient derived from the host SSH key) in
`.sops.yaml` and creates/re-encrypts `secrets/secrets.yaml`. Idempotent; needs
`nix` and an interactive `sudo`.

Then add the user age key:

```bash
mkdir -p ~/.config/sops/age && chmod 700 ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt   # prints the age1... recipient
```

Add the recipient to `.sops.yaml` (`keys:` and the `age:` list in
`creation_rules`), then re-encrypt (see below).

## Edit values

Encrypt from a plaintext file (no identity needed):

```bash
printf '{"key":"value"}\n' > /tmp/secrets.json
nix shell nixpkgs#sops -c sops -e --input-type json --output-type yaml \
  --filename-override secrets/secrets.yaml --output secrets/secrets.yaml /tmp/secrets.json
rm -f /tmp/secrets.json
```

Or interactively (needs the user age key):

```bash
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

New secret: add a key in the file, wire it up in
`modules/nixos/tools/sops.nix`, rebuild. The user's login password is
`user-password-hash` (a `mkpasswd -m sha-512-crypt` hash); update it there and
rebuild, `passwd` gets overwritten on activation.

## Re-encrypt (new key / host)

```bash
nix shell nixpkgs#sops -c sops updatekeys --yes secrets/secrets.yaml
```

> [!IMPORTANT]
> `updatekeys` must decrypt the data key first. A brand-new host with only its
> new host key cannot self-join; restore the user age key on it first, or
> re-encrypt from plaintext on an existing host.

## Adding a new host

1. On the new host: `bash install/init-secrets.sh` (registers it, commits)
2. On an existing host: pull, `sops updatekeys --yes secrets/secrets.yaml`
3. Commit + push; rebuild on the new host

## Reinstalls / recovery

`install/install.sh` restores the host key automatically: it finds
`secrets/key-backup-<hostname>.tar.age` (default `HOST_KEY_SRC=$PWD/secrets`),
prompts for the backup passphrase, decrypts, and stages the key into the new
system. Without the backup, previously committed secrets cannot be decrypted
at activation; a wrong passphrase aborts the install before the wipe.

Brand-new host with no backup yet: pregenerate a key and install with `SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key` (see
[installation.md](installation.md#new-host)), then register it above and
create its first backup with `key-backup.sh encrypt`.
