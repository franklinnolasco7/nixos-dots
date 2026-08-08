```text
nixos-dots/
├── flake.nix
├── flake.lock
├── shell.nix
├── .editorconfig
├── README.md
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
│       │   ├── kitty.nix
│       │   ├── btop.nix
│       │   └── fastfetch.nix
│       │
│       └── development/
│           ├── git.nix
│           ├── neovim.nix
│           ├── node.nix
│           ├── rust.nix
│           └── python.nix
│
├── users/
│   └── frank/
│       ├── default.nix
│       └── home.nix
│
├── config/
│   ├── hypr/
│   │   ├── hyprland.lua
│   │   └── hyprlock.conf
│   ├── waybar/
│   │   ├── config.jsonc
│   │   └── style.css
│   ├── rofi/
│   │   ├── config.rasi
│   │   └── scripts/
│   ├── swaync/
│   │   └── config.json
│   ├── kitty/
│   │   └── kitty.conf
│   ├── btop/
│   │   └── btop.conf
│   ├── fastfetch/
│   │   └── config.jsonc
│   └── nvim/
│       ├── init.lua
│       └── lua/
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
├── secrets/
│   └── .gitkeep
│
├── install/
│   ├── install.sh
│   ├── aspire7.sh
│   ├── rebuild.sh
│   ├── update.sh
│   └── format.sh
│
└── docs/
    ├── installation.md
    └── architecture.md
```
