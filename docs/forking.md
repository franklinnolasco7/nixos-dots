# Forking

Everything user-specific is declared once; a fork changes three spots and
re-runs the sops bootstrap.

## 1. Rename the user directory

```bash
git mv users/frank users/<your-user>
```

## 2. Point the flake at your user

`flake.nix` — every `mkSystem` call:

```nix
nixosConfigurations.<hostname> = mkSystem {
  hostDir = ./hosts/<hostname>;
  user = "<your-user>";
};
```

The user is passed to both the NixOS modules (`users.nix`, `sops.nix`) and
home-manager (`extraSpecialArgs`), so `home.username` and
`home.homeDirectory` follow automatically.

## 3. Replace the git identity

`users/<your-user>/home.nix`:

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

## 5. Optional cleanups

- `README.md` / `docs/installation.md`: replace the upstream clone URL.
- `docs/installation.md` VPN section: your own `wg0.conf` stays out of the
  repo (see the section for the manual steps).
- `.github/workflows/project-automation.yml` and `CONTRIBUTING.md` reference
  the upstream board — drop or point to your own.
