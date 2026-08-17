# Secrets

sops-nix + age with two keys:

- **Host SSH key** (`/etc/ssh/ssh_host_ed25519_key`); the only decryption identity used at activation via `sops-nix` (`modules/nixos/tools/sops.nix`).
- **User age key** (`~/.config/sops/age/keys.txt`); lets you edit secrets without `sudo` (interactive `sops` / `sops updatekeys`). Not registered as an activation identity: sops-nix decrypts with the host key only.

Config: `.sops.yaml`, module: `modules/nixos/tools/sops.nix`, encrypted data: `secrets/secrets.yaml` (encrypted to every registered recipient).

## Is it safe to commit secrets.yaml?

Yes. `secrets/secrets.yaml` is encrypted (sops/age) to the recipients registered in `.sops.yaml`; anyone without one of those keys sees only an opaque blob. Secrets live in git safely.

Keep these private and backed up; either one can decrypt the encrypted data:

- `/etc/ssh/ssh_host_ed25519_key` (and `.pub`); the activation identity
- `~/.config/sops/age/keys.txt`; interactive editing / `updatekeys`

A reinstall regenerates the host key, making old secrets unreadable at
activation; back the keys up first:

```bash
sudo bash install/key-backup.sh encrypt
```

Packs the host key, the user age key, and `~/.ssh/id_ed25519` into
`secrets/key-backup-<hostname>.tar.age` under an **age passphrase** (scrypt)
and commits + pushes the blob; safe to commit even to a public repo, exactly
like `secrets.yaml`. The passphrase is the only secret in the flow; keep it in
a password manager, lose it and the backup is useless.

The installer decrypts the blob automatically on the ISO (passphrase prompt)
before the wipe and restores the host key. The age key and `id_ed25519` are
optional after boot: `bash install/key-backup.sh decrypt`.

## Bootstrap (first host)

Requires `nix` and an interactive `sudo` (step 4 prompts for the password). Idempotent:

```bash
bash install/init-secrets.sh
```

It derives the host's age recipient from the host SSH key, registers it in `.sops.yaml`, creates `secrets/secrets.yaml` if missing (or re-encrypts it), and verifies decryption via the host key.

Then set up the **user age key** so you can edit without `sudo`:

```bash
mkdir -p ~/.config/sops/age && chmod 700 ~/.config/sops/age
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt   # prints the age1... recipient
```

Add that recipient to `.sops.yaml` under `keys:` and to the `age:` list in `creation_rules`, then re-encrypt so both keys can decrypt (see below).

## Set / edit values

**Easiest (no identity needed):** encrypt from a plaintext file to the current recipients:

```bash
printf '{"context7-api-key":"...","github-token":"..."}\n' > /tmp/secrets.json
nix shell nixpkgs#sops -c sops -e --input-type json --output-type yaml \
  --filename-override secrets/secrets.yaml --output secrets/secrets.yaml /tmp/secrets.json
rm -f /tmp/secrets.json
```

**Interactive edit** (needs the user age key registered):

```bash
nix shell nixpkgs#sops -c sops secrets/secrets.yaml   # decrypts with ~/.config/sops/age/keys.txt, re-encrypts on save
```

New secret: add a key in the file, wire it up in `modules/nixos/tools/sops.nix`, rebuild.

The user's login password hash lives here as `user-password-hash` (applied by
`users.users.<name>.hashedPasswordFile` on hosts with sops). To change the
password, put a new `mkpasswd -m sha-512-crypt` / `openssl passwd -6` hash under
that key and rebuild; `passwd` on the machine is overwritten by the next
activation.

## Re-encrypt (new key / host)

```bash
nix shell nixpkgs#sops -c sops updatekeys --yes secrets/secrets.yaml
```

> [!IMPORTANT]
> `updatekeys` must decrypt the data key first. A host whose only identity is
> its (new) host key cannot self-join; but if the **user age key**
> (`~/.config/sops/age/keys.txt`) is restored/present, decryption works and the
> new host *can* self-join.

## Adding a new host

1. On the new host: clone the repo, run `bash install/init-secrets.sh`. It registers the new host in `.sops.yaml` and pushes/commits it.
2. On any existing (already-decrypting) host: pull, then `sops updatekeys --yes secrets/secrets.yaml` to re-encrypt to the new recipient.
3. Commit + push; rebuild on the new host.

If the new host must read the secrets before an existing host can re-encrypt, first add the new recipient, then re-encrypt from plaintext as above.

## Reinstalls / recovery

`install/install.sh` restores the host key `/etc/ssh/ssh_host_ed25519_key{,.pub}`
automatically: it finds `secrets/key-backup-<hostname>.tar.age` (default
`HOST_KEY_SRC=$PWD/secrets`), prompts for the backup passphrase, decrypts, and
stages the key into the new system via `--extra-files`. Without the backup,
previously committed secrets cannot be decrypted by sops-nix at activation; a
wrong passphrase aborts the install before the wipe.

After boot, restore the optional user keys (interactive `sops` editing, SSH
client / git-signing key; activation uses only the host key):

```bash
bash install/key-backup.sh decrypt   # passphrase prompt; --dir DIR stages instead
```
