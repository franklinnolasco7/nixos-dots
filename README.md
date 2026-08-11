# nixos-dots

Personal NixOS & Home Manager dotfiles managed with Flakes and Disko.

## Features

- **Window Manager**: Hyprland (Lua configuration, Waybar, Rofi, SwayNC)
- **Environment**: Flakes + Home Manager
- **Disk Management**: Disko partitioning & Btrfs subvolumes
- **Secrets Management**: sops-nix with age / SSH key encryption
- **Theming**: Dimspectra dark color palette & macOS cursors (`apple-cursor`)

## Quick Commands

Rebuild system configuration:
```bash
./install/rebuild.sh
```

Update flake inputs & rebuild:
```bash
./install/update.sh
```

Format codebase (Nix, Lua, Shell, TOML):
```bash
./install/format.sh
```

## Documentation

- [Installation Guide](docs/installation.md)
- [Architecture Overview](docs/architecture.md)
- [Theme Specification](themes/dimspectra.md)
