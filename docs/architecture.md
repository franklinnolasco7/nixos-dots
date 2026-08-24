# Architecture

`nixos-dots` flows: **flake → hosts → NixOS modules → user → Home Manager modules**, all reproducible via one flake. The flake also exposes disko configurations built from the same host dirs, and pins `nixos-anywhere` (`apps.nixos-anywhere`) to run the installer.

## Layout

```text
nixos-dots/
├── flake.nix      # entry point: inputs, mkSystem/mkDisko helpers, nixosConfigurations + diskoConfigurations
├── flake.lock
├── .sops.yaml     # sops recipients (dedicated host + user age keys)
├── hosts/         # per-machine config
│   ├── aspire7/   #   physical laptop: default.nix entry, hw-config, disko.nix, configuration.nix (PRIME, DM), acer-battery
│   └── vm/        #   QEMU/KVM rehearsal VM: same GPT layout, targets /dev/vda
├── modules/
│   ├── nixos/     # reusable system modules, grouped into categories
│   │   ├── system/   # base OS (common, boot, gc, networking, hardware, audio, printing, smartd, hardening, ...)
│   │   └── tools/    # feature modules (desktop, gaming, virtualization, nvidia, samba, sops)
│   ├── home/      # reusable home modules, grouped into categories
│   │   ├── wayland/   # desktop stack, one folder per app (hyprland, hypridle, hyprlock, waybar, rofi, swaync, gpu-screen-recorder); full profile only
│   │   ├── terminal/  # per-app folders (zsh, starship, btop, htop, fastfetch, cava) imported by shell.nix, + flat aggregators emulator.nix (kitty) and tui.nix (full only)
│   │   ├── programs/  # standalone apps, one folder per app (micro, restic; firefox, gaming, obsidian, opencode, spotify, thunar, vesktop, full only)
│   │   ├── development/ # dev tooling (git; toolchain, full only)
│   │   ├── styling/   # appearance (gtk, qt, cursor, fonts)
│   │   ├── xdg/       # desktop integration (mimetypes); full profile only
│   │   └── scripts/   # helper binaries (airplane-mode, vpn-toggle, battery-notify, ...); full profile only
│   └── disko/     # shared GPT partition layout (gpt-layout.nix)
├── users/frank/   # per-user home-manager entry point (default.nix)
├── pkgs/          # custom derivations (graphite-gtk-theme)
├── overlays/      # exports pkgs/* into the nixpkgs set
├── themes/
│   └── wallpapers/ # committed pool; subfolders = gitignored local temp sets
├── install/       # ops: install.sh, rebuild.sh, update.sh, format.sh, init-secrets.sh, key-backup.sh, run-vm.sh, aspire7.sh
├── docs/          # one page per topic
└── secrets/       # sops-encrypted (committed; enabled via modules/nixos/tools/sops.nix)
```

## Wallpapers

`themes/wallpapers/` holds the committed pool. Subfolders are gitignored
(`themes/wallpapers/*/`), so add any personal folder; never committed. The
`wallpaper` picker scans all subfolders, listing images by file name only.

## Configuration Flow

```text
flake.nix
    ▼
hosts/<name>/  (default.nix → hardware-configuration.nix, configuration.nix)
    ▼
modules/nixos/  (default.nix pulls system/ + tools/ categories)
    ▼
users/<user>/default.nix  (home-manager entry point)
    ▼
modules/home/  (default.nix pulls wayland/terminal/programs/development/styling/xdg/scripts categories)
    ▼
home-manager  (programs.*.settings, xdg.configFile, home.file; all native)
```

Disk layout lives in `hosts/<name>/disko.nix`: it pins the target `device` and
imports the shared layout from `modules/disko/gpt-layout.nix`. The same file
feeds two consumers:

- `diskoConfigurations.<name>`; manual disko runs (`nix run .#disko -- ...`).
- the NixOS module list (via `mkSystem`); `disko.nixosModules.disko` turns the
  layout into `fileSystems`/`swapDevices` at build time, so the regenerated
  `hardware-configuration.nix` is UUID-free.

During installation, `nixos-anywhere` (phases `disko,install`) runs the
system's disko script, regenerates `hardware-configuration.nix`
(`--no-filesystems`), and installs the built toplevel.

## Declarative configs only

Every user config is declared natively inside `modules/home/`; either through
home-manager's typed `programs.*.settings` options or through
`xdg.configFile`/`home.file` with the config written inline in the module. Apps
with large configs are split across `config.nix` / `style.nix` / `scripts.nix`
(e.g. hyprland, waybar, rofi, swaync); standalone helper binaries live as
per-script modules under `scripts/`. There is no raw config directory to
drift from Nix.

## Where does new config go?

- **A new app → a folder.** Standalone apps live in `modules/home/<category>/<app>/` with a `default.nix`; pick the category that matches what the app is (GUI stack in `wayland/`, shell/TUI in `terminal/`, everything else in `programs/`). Split a large app's module into `config.nix` / `style.nix` / `scripts.nix` inside its folder. Only aggregators that group per-app folders by profile (e.g. `terminal/shell.nix`, `terminal/emulator.nix`) sit flat in the category.
- **A new setting/feature, not an app → a flat file.** Config domains (`development/`, `styling/`, `xdg/`, `scripts/`) and NixOS categories (`system/`, `tools/`) are one `.nix` per concern. A single concern under ~50 lines doesn't earn a folder. Split a file only when one `config` block starts covering unrelated tools.
- **A shared helper or data file → keep it in-tree, imported, not imported-as-module.** Shared libs/data (palette, toggle writers) live beside the modules that use them, are imported by those modules, and stay out of the category's `default.nix` imports.
- **An app or feature with both system and user sides** → put each side under whichever module system owns the option: system services under `modules/nixos/`, user prefs under `modules/home/`. If home-manager has no option for the system part, the system side must live in `modules/nixos/` regardless of where the user side sits.

## Hosts

- `aspire7`; the physical machine. Host-specific pieces live in
  `hosts/aspire7/`: NVIDIA PRIME bus IDs, `acer-battery`; the
  OS disk is pinned by-id in `disko.nix`. NVMe health (wear, pending sectors,
  temp) is watched by smartd (`modules/nixos/system/smartd.nix`); alerts go to
  wall, not mail; no MTA is configured. SSH is key-only with root login
  disabled (`modules/nixos/system/hardening.nix`), reachable only through the
  default-deny firewall's port 22 allowlist (`modules/nixos/system/firewall.nix`).
- `vm`; QEMU/KVM rehearsal host. Reuses the same GPT layout on `/dev/vda` to
  rehearse the installer 1:1, but skips host-specific modules (nvidia,
  acer-battery, sops).

### Host hardware defaults

Shared modules must not hardcode laptop device paths. Hardware paths are
exposed as typed `myHost.*` options in `modules/nixos/options.nix` and
`modules/home/options.nix` (`batteryPath`, `backlightDevice`), default `""`
meaning the feature is skipped. `hosts/<name>/` sets the values for the real
machine (`hosts/aspire7/configuration.nix`, `hosts/aspire7/home.nix`); a fork
or the VM that leaves them unset degrades cleanly instead of inheriting the
wrong battery or backlight.

## Profiles

Every host has two flake configurations: the **full** desktop profile
(`.#<host>`, the default) and the **minimal** console-TTY profile
(`.#<host>-min`).

| Config        | profile   | Contents |
| ------------- | --------- | -------- |
| `aspire7`     | full      | Wayland stack, GUI apps, gaming, virtualization, NVIDIA |
| `aspire7-min` | minimal   | console TTY: zsh, starship (ASCII), btop, htop, fastfetch (ASCII), cava, micro, git, core CLI tools |
| `vm`          | full      | Wayland stack (no nvidia/sops) |
| `vm-min`      | minimal   | same as aspire7-min |

The profile is injected by `flake.nix` `mkSystem` as the **typed** `myProfile`
option on both module systems (`modules/nixos/options.nix` and
`modules/home/options.nix`); `enum [ "full" "minimal" ]`, default `full`. A
typo in a flake profile fails eval on the enum, never silently. Body gates read
`config.myProfile`. Because the module system forbids referencing `config` in
`imports` (infinite recursion), `imports` lists branch on the raw `profile`
value threaded through `specialArgs` / `home-manager.extraSpecialArgs`; the
two mechanisms never mix.

The minimal profile gates out, on the NixOS side: the shared desktop module
(`modules/nixos/tools/desktop.nix`: ly, Hyprland, portal, gvfs, dconf),
gnome-keyring, NVIDIA driver + PRIME, firefox, and the
`gaming`/`virtualization` tool modules. On the
home side:
the `wayland`, `xdg`, and `scripts` categories, kitty, opencode, the dev
toolchain, GUI packages (firefox, thunar, vscodium, ...), and GTK/Qt/cursor
theming. Starship and fastfetch fall back to ASCII (no nerd glyphs, no kitty
image logo). `system.nixos.label` is `"<hostname>-<profile>"`, so systemd-boot
shows `nixos-laptop` vs `nixos-laptop-minimal`.

> [!IMPORTANT]
> The `-min` suffix is **reserved** for profile variants of an existing host.
> It is never a real hostname. `hosts/<name>-min/` must not be created;
> `install/rebuild.sh` maps `<host>-min` → `.#<host>-min`.

## Flake Inputs

- `nixpkgs`; `nixos-unstable`. Hyprland is no longer a flake input: both sides
  (NixOS `programs.hyprland`, home-manager `wayland.windowManager.hyprland`)
  resolve from this pinned nixpkgs.
- `chaotic`; nyx `nyxpkgs-unstable`, served from the nyx binary cache. Provides
  the CachyOS kernel + NVIDIA drivers (`linuxPackages_cachyos`, `nvidia_cachyos`).
- `nvidia-patch`; follows nixpkgs. FBC/NVENC patch overlay for the NVIDIA
  driver (used in `modules/nixos/tools/nvidia.nix`).
- `spicetify-nix`; Spicetify home-manager module + package set, consumed by the
  spotify module (`modules/home/programs/spotify/default.nix`).
- `obsidian-extensions`; overlay providing Obsidian community plugins/themes
  (`pkgs.obsidianPlugins`, `pkgs.obsidianThemes`), used in
  `modules/home/programs/obsidian/default.nix`.
- `mcp-servers-nix`; follows nixpkgs. MCP servers for opencode
  (`modules/home/programs/opencode/default.nix`).
- `home-manager`, `sops-nix`, `disko`, `nixos-anywhere`; follow nixpkgs.
