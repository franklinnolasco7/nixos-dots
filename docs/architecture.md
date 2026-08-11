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
├── .sops.yaml
│
├── hosts/
│   └── aspire7/
│       ├── default.nix
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       ├── acer-battery.nix
│       └── disko.nix
│
├── modules/
│   ├── nixos/
│   │   ├── default.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── hardware.nix
│   │   ├── tuning.nix
│   │   ├── nvidia.nix
│   │   ├── audio.nix
│   │   ├── bluetooth.nix
│   │   ├── users.nix
│   │   ├── sops.nix
│   │   ├── virtualization.nix
│   │   └── gaming.nix
│   │
│   └── home/
│       ├── default.nix
│       │
│       ├── hyprland.nix
│       ├── hyprctl.nix
│       ├── waybar.nix
│       ├── rofi.nix
│       ├── swaync.nix
│       ├── wallpapers.nix
│       │
│       ├── zsh.nix
│       ├── starship.nix
│       ├── kitty.nix
│       ├── btop.nix
│       ├── cava.nix
│       ├── fastfetch.nix
│       ├── htop.nix
│       │
│       ├── micro.nix
│       ├── opencode.nix
│       │
│       ├── git.nix
│       ├── development.nix
│       │
│       ├── packages.nix
│       ├── themes.nix
│       ├── cursor.nix
│       ├── gtk.nix
│       ├── qt.nix
│       ├── xdg.nix
│       └── scripts.nix
│
├── users/
│   └── frank/
│       ├── default.nix
│       └── home.nix
│
├── home/
│   ├── .zshrc
│   ├── .config/
│   │   ├── hypr/
│   │   │   ├── hyprland.lua
│   │   │   └── hyprlock.conf
│   │   ├── hyprctl/
│   │   │   ├── hyprctl.json
│   │   │   └── hyprctl.sh
│   │   ├── waybar/
│   │   │   ├── config.jsonc
│   │   │   ├── config
│   │   │   ├── style.css
│   │   │   └── scripts/
│   │   │       ├── audio-microphone.sh
│   │   │       ├── audio-volume.sh
│   │   │       ├── battery-limit-toggle.sh
│   │   │       ├── bluetooth-toggle.sh
│   │   │       ├── cpu-governor.sh
│   │   │       ├── is-fullscreen.sh
│   │   │       ├── power-profile.sh
│   │   │       ├── swappiness.sh
│   │   │       └── wifi-toggle.sh
│   │   ├── rofi/
│   │   │   ├── config.rasi
│   │   │   ├── theme-wallpaper.rasi
│   │   │   ├── colors/
│   │   │   │   └── monochrome.rasi
│   │   │   ├── shared/
│   │   │   │   ├── colors.rasi
│   │   │   │   └── fonts.rasi
│   │   │   └── scripts/
│   │   │       ├── cliphist-rofi-img.sh
│   │   │       ├── hypr-keybinds.lua
│   │   │       ├── hypr-keybinds.sh
│   │   │       ├── rofi-web-search.sh
│   │   │       └── wallpaper.sh
│   │   ├── swaync/
│   │   │   ├── config.json
│   │   │   ├── config.schema.json
│   │   │   ├── style.css
│   │   │   ├── scripts/
│   │   │   │   ├── critical-sound.sh
│   │   │   │   └── default-sound.sh
│   │   │   └── sounds/
│   │   │       ├── default.ogg
│   │   │       └── important.ogg
│   │   ├── kitty/
│   │   │   └── kitty.conf
│   │   ├── btop/
│   │   │   └── btop.conf
│   │   ├── cava/
│   │   │   ├── config
│   │   │   ├── shaders/
│   │   │   │   ├── bar_spectrum.frag
│   │   │   │   ├── eye_of_phi.frag
│   │   │   │   ├── northern_lights.frag
│   │   │   │   ├── pass_through.vert
│   │   │   │   ├── spectrogram.frag
│   │   │   │   └── winamp_line_style_spectrum.frag
│   │   │   └── themes/
│   │   │       ├── solarized_dark
│   │   │       └── tricolor
│   │   ├── fastfetch/
│   │   │   ├── config.jsonc
│   │   │   └── logo.jpg
│   │   ├── htop/
│   │   │   └── htoprc
│   │   ├── micro/
│   │   │   ├── bindings.json
│   │   │   ├── settings.json
│   │   │   └── colorschemes/
│   │   │       └── dimspectra.micro
│   │   ├── opencode/
│   │   │   └── config.json
│   │   ├── starship.toml
│   │   └── mimeapps.list
│   │
│   └── .local/
│       └── bin/
│           ├── airplane-mode.sh
│           ├── annotate-last-screenshot.sh
│           ├── battery-notify.sh
│           ├── toggle-laptop-kb.sh
│           ├── toggle-laptop-tp.sh
│           └── vpn-toggle.sh
│
├── themes/
│   ├── colors.nix
│   ├── dimspectra.md
│   └── wallpapers/
│
├── install/
│   ├── aspire7.sh
│   ├── format.sh
│   ├── init-secrets.sh
│   ├── install.sh
│   ├── rebuild.sh
│   └── update.sh
│
├── docs/
│   ├── architecture.md
│   └── installation.md
│
└── secrets/
    └── (empty; secrets.yaml created by init-secrets.sh)
```

## Structure

### `hosts/`

Contains **machine-specific configuration**.

Each host defines hardware, system configuration, boot configuration, disk layout, and host-specific hardware settings (e.g. NVIDIA PRIME bus IDs, Acer battery kernel module).

### `modules/nixos/`

Contains reusable **system-level NixOS modules**.

These handle things such as:

* Boot (bootloader, zram swap)
* Networking
* Hardware (graphics, power profiles daemon)
* Tuning (swappiness, CPU governor permissions, scoped sysctl sudo)
* NVIDIA (generic driver settings)
* Audio (PipeWire)
* Bluetooth
* Users
* Secrets (sops-nix)
* Virtualization (placeholder)
* Gaming (placeholder)

### `modules/home/`

Contains reusable **Home Manager modules**.

Modules are organized by purpose:

* **Desktop** — Hyprland, Hyprctl, Waybar, Rofi, SwayNC, Wallpapers
* **Terminal** — Zsh, Starship, Kitty, Btop, Cava, Fastfetch, Htop
* **Editors** — Micro, Opencode
* **Development** — Git, development toolchains (Node.js, Python, Rust)
* **Packages & Theming** — User packages, fonts, GTK/Qt theming, cursor, XDG mimeapps, shell scripts

> [!NOTE]
> Each module either uses Home Manager's native `programs.*` options (Zsh, Starship, Git) or deploys raw config files via `xdg.configFile` / `home.file` for apps with complex native configs (Hyprland Lua, Waybar CSS, Rofi Rasi).

### `users/`

Contains **user-specific configuration**.

The `frank/` directory defines the user's Home Manager entry point (`home.nix`), including session paths, environment variables, and imports of all home modules.

### `home/`

Contains the actual **user configuration files** managed by Home Manager.

This keeps application configuration such as Hyprland, Waybar, Kitty, Fastfetch, and shell scripts separate from the Nix module definitions that install or manage them.

### `themes/`

Contains theme assets and shared theme definitions:

* Wallpapers (deployed to `~/wallpapers` via Home Manager)
* Color palette documentation (dimspectra.md)
* Dimspectra color palette definitions (`colors.nix`) — available for adoption by modules

### `install/`

Contains scripts for common operations:

* `aspire7.sh` — Host installer for the Aspire 7 (Disko partitioning + `nixos-install`)
* `format.sh` — Format all Nix, Lua, shell, and TOML files
* `init-secrets.sh` — One-time bootstrap of sops-encrypted secrets
* `install.sh` — General entrypoint that dispatches to the per-host installer
* `rebuild.sh` — Rebuild the system flake (`switch`/`boot`/`test`)
* `update.sh` — Update flake inputs, then rebuild

### `docs/`

Project documentation (`architecture.md`, `installation.md`).

### `secrets/`

Reserved for sops-encrypted secrets. The `secrets.yaml` file is created by `init-secrets.sh` and encrypted with age.

> [!TIP]
> The sops module is gated behind a `pathExists` check so builds succeed before secrets are bootstrapped.

## Configuration Flow

```text
flake.nix
    │
    ▼
hosts/aspire7/
    │
    ├── hardware-configuration.nix  (generated, hardware-specific)
    ├── acer-battery.nix            (host-specific Acer battery module)
    ├── configuration.nix           (host settings, NVIDIA PRIME, nix.settings)
    └── disko.nix                   (disk layout, separate from nixosConfigurations)
    │
    ▼
modules/nixos/                      (reusable system modules)
    │
    ▼
users/frank/home.nix                (user entry point, sessionPath, sessionVariables)
    │
    ▼
modules/home/                       (reusable home modules)
    │
    ▼
home/.config/ + home/.local/bin/    (raw application configs + scripts)
```

The goal is to keep **machine-specific settings, reusable modules, user configuration, and application configuration separated** while keeping the entire system reproducible through the flake.

## Flake Inputs & Infrastructure

### Chaotic-Nyx Integration

`chaotic-nyx` (`github:chaotic-cx/nyx/nyxpkgs-unstable`) is registered via `chaotic.nixosModules.default` on `aspire7`.

* **Purpose**: Bleeding-edge packages (e.g., `mesa_git`, `linux_cachyos`, `firefox_nightly`, `sway_git`, `gamescope_git`) and binary cache (`chaotic.nyx.cache.enable = true`).

> [!NOTE]
> Infrastructure-only pass. No packages or custom `chaotic.*` options enabled yet.

> [!IMPORTANT]
> `inputs.chaotic.inputs.nixpkgs.follows` intentionally omitted — Chaotic-Nyx pins its own nixpkgs to preserve binary cache hits.

### Reproducibility Notes

> [!WARNING]
> `nyxpkgs-unstable` moves independently from `nixos-unstable`. `flake.lock` maintains deterministic builds, but cross-channel version skew adds maintenance overhead.

> [!CAUTION]
> `chaotic.nyx.cache.enable = true` trusts a third-party binary cache and external `nixpkgs` pin, introducing a second trust root into the system closure.
