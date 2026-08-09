# Architecture

`nixos-dots` is organized around a **host → NixOS modules → Home Manager modules → user configuration** structure.

```text
nixos-dots/
├── flake.nix
├── flake.lock
├── shell.nix
├── README.md
├── TODO.md
├── .editorconfig
├── .gitignore
│
├── hosts/
│   └── aspire7/
│       ├── default.nix
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── disko.nix
│
├── modules/
│   ├── nixos/
│   │   ├── default.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── hardware.nix
│   │   ├── nvidia.nix
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   ├── users.nix
│   │   ├── virtualization.nix
│   │   └── gaming.nix
│   │
│   └── home/
│       ├── default.nix
│       ├── home.nix
│       ├── packages.nix
│       │
│       ├── desktop/
│       │   ├── hyprland.nix
│       │   ├── waybar.nix
│       │   ├── rofi.nix
│       │   └── swaync.nix
│       │
│       ├── terminal/
│       │   ├── zsh.nix
│       │   ├── starship.nix
│       │   ├── kitty.nix
│       │   ├── btop.nix
│       │   └── fastfetch.nix
│       │
│       ├── development/
│       │   ├── git.nix
│       │   ├── neovim.nix
│       │   ├── node.nix
│       │   ├── rust.nix
│       │   └── python.nix
│       │
│       └── themes.nix
│
├── users/
│   └── frank/
│       ├── default.nix
│       └── home.nix
│
├── home/
│   ├── .zshrc
│   └── .config/
│       ├── hypr/
│       │   ├── hyprland.lua
│       │   └── hyprlock.conf
│       ├── waybar/
│       │   ├── config.jsonc
│       │   └── style.css
│       ├── rofi/
│       │   ├── config.rasi
│       │   └── scripts/
│       ├── swaync/
│       │   └── config.json
│       ├── kitty/
│       │   └── kitty.conf
│       ├── btop/
│       │   └── btop.conf
│       ├── fastfetch/
│       │   └── config.jsonc
│       └── nvim/
│           ├── init.lua
│           └── lua/
│
├── themes/
│   ├── wallpapers/
│   │   ├── desktop/
│   │   └── lockscreen/
│   ├── cursors/
│   │   └── macOS-White/
│   ├── icons/
│   ├── fonts/
│   └── colors.nix
│
├── pkgs/
│   └── default.nix
│
├── overlays/
│   └── default.nix
│
├── install/
│   ├── install.sh
│   ├── aspire7.sh
│   ├── rebuild.sh
│   ├── update.sh
│   └── format.sh
│
├── docs/
│   ├── installation.md
│   └── architecture.md
│
└── secrets/
    └── .gitkeep
```

## Structure

### `hosts/`

Contains **machine-specific configuration**.

Each host defines hardware, system configuration, boot configuration, and disk layout.

### `modules/nixos/`

Contains reusable **system-level NixOS modules**.

These handle things such as:

* Boot
* Networking
* Hardware
* NVIDIA
* Audio
* Bluetooth
* Users
* Virtualization
* Gaming

### `modules/home/`

Contains reusable **Home Manager modules**.

Modules are grouped by purpose:

* `desktop/` — Hyprland, Waybar, Rofi, SwayNC
* `terminal/` — Zsh, Starship, Kitty, Btop, Fastfetch
* `development/` — Git, Neovim, Node.js, Rust, Python
* `themes.nix` — fonts and theme-related packages

### `users/`

Contains **user-specific configuration**.

The `frank/` directory defines the user's Home Manager configuration separately from machine-level configuration.

### `home/`

Contains the actual **user configuration files** managed by Home Manager.

This keeps application configuration such as Hyprland, Waybar, Kitty, Fastfetch, and Neovim separate from the Nix module definitions that install or manage them.

### `themes/`

Contains theme assets and shared theme definitions:

* Wallpapers
* Cursors
* Icons
* Fonts
* Shared colors

### `pkgs/`

Contains custom Nix packages defined specifically for the system.

### `overlays/`

Contains Nixpkgs overlays for modifying or extending packages.

### `install/`

Contains scripts for installation and common system operations such as rebuilding, updating, and formatting.

### `docs/`

Project documentation.

### `secrets/`

Reserved for secrets and secret-management files. Secrets should **not** be committed to Git.

## Configuration Flow

```text
flake.nix
    │
    ▼
hosts/aspire7/
    │
    ├── configuration.nix
    ├── hardware-configuration.nix
    └── disko.nix
    │
    ▼
modules/nixos/
    │
    ▼
users/frank/
    │
    ▼
modules/home/
    │
    ▼
home/.config/
```

The goal is to keep **machine-specific settings, reusable modules, user configuration, and application configuration separated** while keeping the entire system reproducible through the flake.
