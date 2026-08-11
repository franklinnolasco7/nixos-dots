# Secrets

sops-nix + age, **host SSH key** (`/etc/ssh/ssh_host_ed25519_key`). Config: `.sops.yaml`, module: `modules/nixos/sops.nix`.

Age recipients are per-host: each NixOS host derives its own recipient from its host key. One shared `secrets/secrets.yaml`, encrypted to every registered host.

## Bootstrap / Register a host

On the host (after clone/pull), run the idempotent bootstrap:

```bash
bash install/init-secrets.sh   # registers host key in .sops.yaml, creates/re-encrypts secrets file
```

It derives the host's age recipient from the host SSH key, appends it to `.sops.yaml` if missing, creates an encrypted skeleton (`secrets/secrets.yaml`) if absent, and re-encrypts to every registered host. Run once per host.

## Fill values

On any registered host:

```bash
sops secrets/secrets.yaml   # edits, encrypts to all hosts on save
```

New secret: add key in file, wire it in `modules/nixos/sops.nix`, rebuild.

## Re-Encrypt (new key / host)

```bash
nix run nixpkgs#sops -- updatekeys secrets/secrets.yaml
```

Append the host to `.sops.yaml` first (or just re-run `install/init-secrets.sh`).

## Reinstalls

Host keys regenerate on reinstall → old secrets become unreadable. Back up `/etc/ssh/` before wiping (or use impermanence), restore it after.

> [!NOTE]
> Builds work before secrets exist — module is gated behind `pathExists`.