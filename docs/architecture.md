# Architecture

`nixos-dots` flows: **host → NixOS modules → Home Manager modules → user config**, all reproducible via one flake.

## Layout

```text
nixos-dots/
├── flake.nix      # entry point: inputs, mkSystem/mkDisko helpers, nixosConfigurations
├── hosts/         # per-machine config (aspire7: hardware, disko, PRIME)
├── modules/
│   ├── nixos/     # reusable system modules (boot, gc, networking, audio, ...)
│   └── home/      # reusable home modules (hyprland, zsh, git, ...)
├── users/frank/   # home-manager entry point (session paths, imports)
├── home/          # raw app configs + scripts deployed by home modules
├── pkgs/          # custom derivations (graphite-gtk-theme), exported via overlays/
├── themes/        # wallpapers
├── install/       # ops: install, rebuild, update, format, init-secrets
├── docs/          # one page per topic
└── secrets/       # sops-encrypted, gated behind pathExists
```

## Configuration Flow

```text
flake.nix
    ▼
hosts/aspire7/  (hardware-configuration.nix, disko.nix, configuration.nix)
    ▼
modules/nixos/  (reusable system modules)
    ▼
users/frank/home.nix  (user entry point)
    ▼
modules/home/  (reusable home modules)
    ▼
home/.config/ + home/.local/bin/  (raw configs + scripts)
```

## Flake Inputs

- `chaotic` — nyxpkgs-unstable: bleeding-edge pkgs + binary cache. Pins own nixpkgs (cache hits); no `chaotic.*` options enabled yet. Second trust root.
- `hyprland` — flake input, not nixpkgs. Pins own nixpkgs (reproducible builds + `hyprland.cachix.org`). Portals: `xdg-desktop-portal-gtk` extra, `hyprland` + `gtk` default.
- `home-manager`, `sops-nix`, `disko` — follow nixpkgs.