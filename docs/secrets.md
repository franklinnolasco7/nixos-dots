# Secrets

sops-nix with age keys (SSH key `~/.ssh/id_ed25519`). Config: `.sops.yaml` + `modules/nixos/sops.nix`.

## Bootstrap (one-time, on the NixOS machine)

```bash
bash install/init-secrets.sh   # checks age key, collects keys, encrypts secrets/secrets.yaml
git add secrets/secrets.yaml && git commit && git push
./install/rebuild.sh
```

## Edit / Add Secrets

```bash
sops secrets/secrets.yaml      # opens editor, encrypts on save
```

For a new secret: add the key inside the file, then wire it up in `modules/nixos/sops.nix` (path, owner, mode) and rebuild.

## Re-Encrypt (new key added)

```bash
nix run nixpkgs#sops -- updatekeys secrets/secrets.yaml
```

Update the recipient in `.sops.yaml` first.

> [!NOTE]
> Builds succeed before secrets exist — the sops module is gated behind a `pathExists` check.