# Secrets

sops-nix + age (SSH key `~/.ssh/id_ed25519`). Config: `.sops.yaml`, module: `modules/nixos/sops.nix`.

## Bootstrap

On the NixOS machine:

```bash
bash install/init-secrets.sh   # checks age key, encrypts secrets/secrets.yaml
```

## Edit / Add

```bash
sops secrets/secrets.yaml   # edits, encrypts on save
```

New secret: add key in file, wire it in `modules/nixos/sops.nix`, rebuild.

## Re-Encrypt (new key)

```bash
nix run nixpkgs#sops -- updatekeys secrets/secrets.yaml
```

Update recipient in `.sops.yaml` first.

> [!NOTE]
> Builds work before secrets exist — module is gated behind `pathExists`.