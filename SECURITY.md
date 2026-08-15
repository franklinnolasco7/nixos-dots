# Security Policy

## Reporting a vulnerability

Report security issues privately via a **GitHub private security advisory**:

1. Repo → **Security** → **Report a vulnerability**
2. Fill in the draft. It stays private until published. No public issue or PR first.

> [!IMPORTANT]
> Suspect a secret is exposed? Report immediately. Exposed secrets are rotated, not patched.

Include: repo revision (`git log -1 --format=%h`), host/profile affected, reproduction, impact, and whether a secret may be at risk.

## In scope

- Leaked, weak, or mis-scoped secrets
- sops/age misconfiguration, unencrypted material in git, secrets in the Nix store
- Eval-time impurity (flake reading the build machine)
- Supply-chain concerns with pinned flake inputs
- Privilege escalation via the declarative config

## Out of scope

- Upstream bugs (nixpkgs, NixOS, home-manager, sops-nix, Hyprland, disko, nixos-anywhere) → their trackers
- Hardening ideas → feature request. Usage questions → `question` template.

## Posture

- Secrets: sops/age, encrypted in git, never in the store ([docs/secrets.md](docs/secrets.md))
- Host SSH key is the only activation identity
- Flake purity enforced: no `--impure`, no eval-time machine reads
- Inputs pinned deliberately, no silent `nix flake update`

Single-maintainer repo, no SLA. Disclosures go through the advisory.
