# Secrets

sops-nix + age with two decryption identities, plus an independent SSH
identity:

- **Dedicated host age key** (`/etc/sops-nix/keys.txt`): the only identity
  used at activation (`modules/nixos/tools/sops.nix`, `sops.age.keyFile`).
  Decoupled from the SSH host key: rotating `/etc/ssh/ssh_host_ed25519_key`
  never affects secret decryption.
- **User age key** (`~/.config/sops/age/keys.txt`): lets you edit secrets
  without `sudo`.
- **SSH host key** (`/etc/ssh/ssh_host_ed25519_key`): SSH authentication
  only. Independent of sops; backed up for host-identity stability across
  reinstalls, but no longer load-bearing for secrets.

The **private** host age key is never committed to Git: `.gitignore` blocks
everything under `secrets/` except the encrypted `secrets.yaml` and the
passphrase-encrypted `key-backup-*.tar.age` blobs. The dedicated private key
must be backed up separately, in Bitwarden (see [Backup](#backup)).

Encrypted data: `secrets/secrets.yaml`, encrypted to the recipients listed in
`.sops.yaml`. Safe to commit: without a key it is an opaque blob.

## Backup (before reinstalls)

```bash
sudo bash install/key-backup.sh encrypt
```

Packs the dedicated sops age key, the SSH host key, the user age key and
`~/.ssh/id_ed25519` into `secrets/key-backup-<hostname>.tar.age` (age
passphrase, scrypt) and commits + pushes it. The passphrase is one secret;
keep it in a password manager.

The dedicated sops age key is an **independent recovery artifact**: also
export `/etc/sops-nix/keys.txt` to **Bitwarden** (secure note / attachment).
Recovery must never depend on the machine's live copy or on the blob, and the
blob must never depend on the key: it opens with the passphrase alone, so the
two paths (Bitwarden, blob + passphrase) stay independent.

The installer's passphrase prompt decrypts the blob before the wipe and
restores the **dedicated sops age key** (to `/etc/sops-nix/keys.txt`) and the
**SSH host key** into the new system. After boot, restore the personal keys
separately, before the first signed commit:

```bash
bash install/key-backup.sh decrypt
```

Never run that with `sudo` (the user keys land in `/root`; the sops age key
is restored to `/etc` through sudo automatically, with an overwrite prompt);
answer `y` to the overwrite prompt if the boot-time key hook already
generated one; verify afterwards with `ssh-keygen -lf ~/.ssh/id_ed25519.pub`
against your GitHub key.

## Bootstrap (first host)

```bash
bash install/init-secrets.sh
```

Derives the host recipient from the dedicated age key (`age-keygen -y
/etc/sops-nix/keys.txt`), registers it in `.sops.yaml` and creates /
re-encrypts `secrets/secrets.yaml`. Idempotent; needs `nix` and an
interactive `sudo` (to read the root-owned key).

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
`modules/nixos/tools/sops.nix`, then rebuild. Login passwords are not managed
by sops; set them directly with `passwd`.

## Re-encrypt (new key / host)

```bash
nix shell nixpkgs#sops -c sops updatekeys --yes secrets/secrets.yaml
```

> [!IMPORTANT]
> `updatekeys` must decrypt the data key first. A brand-new host with only its
> new dedicated age key cannot self-join; restore the user age key on it
> first, or re-encrypt from plaintext on an existing host.

## Adding a new host

1. On the new host: `bash install/init-secrets.sh` (registers it, commits)
2. On an existing host: pull, `sops updatekeys --yes secrets/secrets.yaml`
3. Commit + push; rebuild on the new host

## Fresh host behavior (`sops.age.generateKey`)

`sops.age.generateKey = true` is a bootstrap **fallback**, not recovery: if
`/etc/sops-nix/keys.txt` is absent at activation, sops-nix mints a random
identity. That identity is **not an authorized recipient** of the repository's
existing encrypted secrets, so committed secrets fail closed (decryption at
activation fails) until the real key is provisioned.

- Existing installations: stage/provision the intended dedicated age key
  **before** activation. `install.sh` does this automatically from the key
  backup, or manually:
  ```bash
  nix shell nixpkgs#age -c age-keygen -o /tmp/sops-age-key.txt
  sudo install -d -m 0700 /etc/sops-nix
  sudo install -m 0600 /tmp/sops-age-key.txt /etc/sops-nix/keys.txt
  rm /tmp/sops-age-key.txt
  ```
  > [!NOTE]
  > `/` is tmpfs (impermanence, see [architecture.md](architecture.md));
  > `/etc/sops-nix/keys.txt` is a bind mount of `/nix/persist/etc/sops-nix/keys.txt`,
  > so the manual install above writes through to the persisted copy. Don't
  > write to the `/nix/persist/...` path directly; the bind mount is the
  > source of truth.
- Fresh hosts: follow the repository's bootstrap/rehearsal flow
  ([installation.md](installation.md#new-host)): pregenerate a key, install
  with `SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key`, then register the
  recipient (`init-secrets.sh`) and re-encrypt from an existing host.
- The chicken-and-egg is by design: a key minted by `generateKey` can only
  decrypt secrets that are then re-encrypted to it; it can never recover
  existing secrets on its own.

## Reinstalls / recovery

`install/install.sh` restores the dedicated sops age key automatically: it
finds `secrets/key-backup-<hostname>.tar.age` (default
`HOST_KEY_SRC=$PWD/secrets`), prompts for the backup passphrase, decrypts, and
stages the key into `/etc/sops-nix/keys.txt` in the new system. Without the
backup (or the Bitwarden copy), previously committed secrets cannot be
decrypted at activation; a wrong passphrase aborts the install before the
wipe.

Brand-new host with no backup yet: pregenerate a key and install with
`SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key` (see
[installation.md](installation.md#new-host)), then register it above and
create its first backup with `key-backup.sh encrypt`.

## Verifying decryption

The file-existence checks (`ls -l ~/.config/opencode/...`) only prove sops
ran; the actual test decrypts the file and prints nothing:

```bash
sudo SOPS_AGE_KEY_FILE=/etc/sops-nix/keys.txt \
  nix run .#sops -- -d secrets/secrets.yaml >/dev/null
```

Use a recovered copy (e.g. from Bitwarden) the same way to prove recovery
works independently of the machine.