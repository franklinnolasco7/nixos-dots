# Forking

Everything user-specific is declared once; a fork changes three spots and
re-runs the sops bootstrap.

## 1. Rename the user directory

```bash
git mv users/frank users/<your-user>
```

## 2. Point the flake at your user

`flake.nix`; every `mkSystem` call:

```nix
nixosConfigurations.<hostname> = mkSystem {
  hostDir = ./hosts/<hostname>;
  user = "<your-user>";
};
```

The user is passed to both the NixOS modules (`modules/nixos/system/users.nix`, `modules/nixos/tools/sops.nix`) and
home-manager (`extraSpecialArgs`), so `home.username` and
`home.homeDirectory` follow automatically.

## 3. Replace the git identity

`users/<your-user>/default.nix`:

- `programs.git.settings.user` → your `name` + `email` + `signingkey`.
- `home.file.".config/git/allowed_signers"` → your signing public key. Format:

  ```
  <your-email> ssh-<keytype> <base64 key>
  ```

  `programs.git.settings.gpg.ssh.allowedSignersFile` points here, and
  `commit.gpgsign = true` signs every commit with `id_ed25519` (generated on
  first activation by `home.activation.createSshKey`).

## 4. Bootstrap secrets

```bash
bash install/init-secrets.sh
```

Registers the host's age recipient in `.sops.yaml` and re-encrypts
`secrets/secrets.yaml` to it. On a fresh repo without secrets:

```bash
bash install/init-secrets.sh   # creates an encrypted skeleton
# then fill real values (see docs/secrets.md)
```

## 5. Key backup (recommended)

```bash
sudo bash install/key-backup.sh encrypt   # collects keys, encrypts, commits + pushes the blob
```

Backs up this machine's keys (dedicated sops age key, host SSH key, user age
key, `~/.ssh/id_ed25519`) into `secrets/key-backup-<hostname>.tar.age`,
encrypted with an age **passphrase** you choose. Safe to commit even to a
public fork.

- Use your **own** passphrase, in your password manager, not the repo: it is
  a single point of failure, lose it and the backup is useless.
- The dedicated sops age key (`/etc/sops-nix/keys.txt`) is an independent
  recovery artifact: also export it to your password manager (Bitwarden), so
  recovery never depends on this machine or the blob.
- Delete upstream's `secrets/key-backup-*.tar.age`: encrypted to upstream's
  passphrase, it's undecryptable garbage to you, and the installer would
  otherwise prompt for a passphrase you don't have.
- The installer decrypts the blob automatically before wiping; after boot,
  `bash install/key-backup.sh decrypt` restores the sops age key and the user
  keys.

## 6. Optional cleanups

- `README.md` / `docs/installation.md`: replace the upstream clone URL.
- `docs/maintenance.md` VPN section: your own `wg0.conf` stays out of the
  repo (see the section for the sops-secret steps).
- `.github/workflows/project-automation.yml` and `CONTRIBUTING.md` reference
  the upstream board; drop or point to your own.
