# Architecture

`nixos-dots` flows: **flake → hosts → NixOS modules → user → Home Manager modules**, all reproducible via one flake. The flake also exposes disko configurations built from the same host dirs, and pins `nixos-anywhere` (`apps.nixos-anywhere`) to run the installer.

## Layout

```text
nixos-dots/
├── flake.nix      # entry point: inputs, mkSystem/mkDisko helpers, nixosConfigurations + diskoConfigurations
├── flake.lock
├── .sops.yaml     # sops recipients (per-host age keys)
├── hosts/         # per-machine config
│   ├── aspire7/   #   physical laptop: default.nix entry, hw-config, disko.nix, configuration.nix (PRIME, DM), acer-battery
│   └── vm/        #   QEMU/KVM rehearsal VM: same GPT layout, targets /dev/vda
├── modules/
│   ├── nixos/     # reusable system modules, grouped into categories
│   │   ├── system/   # base OS (common, boot, gc, networking, hardware, audio, printing, smartd, hardening, ...)
│   │   └── tools/    # feature modules (nvidia, gaming, virtualization, sops)
│   ├── home/      # reusable home modules, grouped into categories
│   │   ├── wayland/   # desktop stack (hyprland, hypridle, hyprlock, waybar, rofi, swaync) — full profile only
│   │   ├── terminal/  # shell.nix (zsh, starship, btop, htop, fastfetch, cava) + emulator.nix (kitty, full only)
│   │   ├── programs/  # standalone apps (micro; opencode, full only)
│   │   ├── development/ # dev tooling (git; toolchain, full only)
│   │   ├── styling/   # appearance (gtk, qt, cursor, fonts)
│   │   ├── xdg/       # desktop integration (mimetypes) — full profile only
│   │   └── scripts/   # helper binaries (airplane-mode, vpn-toggle, battery-notify, ...) — full profile only
│   └── disko/     # shared GPT partition layout (gpt-layout.nix)
├── users/frank/   # per-user home-manager entry point (default.nix)
├── pkgs/          # custom derivations (graphite-gtk-theme)
├── overlays/      # exports pkgs/* into the nixpkgs set
├── themes/
│   └── wallpapers/ # committed pool; subfolders = gitignored local temp sets
├── install/       # ops: install.sh, rebuild.sh, update.sh, format.sh, init-secrets.sh, backup-host-key.sh, run-vm.sh, aspire7.sh
├── docs/          # one page per topic
└── secrets/       # sops-encrypted (committed; enabled via modules/nixos/tools/sops.nix)
```

## Wallpapers

`themes/wallpapers/` holds the committed pool. Subfolders are gitignored
(`themes/wallpapers/*/`), so add any personal folder — never committed. The
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
home-manager  (programs.*.settings, xdg.configFile, home.file — all native)
```

Disk layout lives in `hosts/<name>/disko.nix`: it pins the target `device` and
imports the shared layout from `modules/disko/gpt-layout.nix`. The same file
feeds two consumers:

- `diskoConfigurations.<name>` — manual disko runs (`nix run .#disko -- ...`).
- the NixOS module list (via `mkSystem`) — `disko.nixosModules.disko` turns the
  layout into `fileSystems`/`swapDevices` at build time, so the regenerated
  `hardware-configuration.nix` is UUID-free.

During installation, `nixos-anywhere` (phases `disko,install`) runs the
system's disko script, regenerates `hardware-configuration.nix`
(`--no-filesystems`), and installs the built toplevel.

## Declarative configs only

Every user config is declared natively inside `modules/home/` — either through
home-manager's typed `programs.*.settings` options or through
`xdg.configFile`/`home.file` with the config written inline in the module. Apps
with large configs are split across `config.nix` / `style.nix` / `scripts.nix`
(e.g. hyprland, waybar, rofi, swaync); standalone helper binaries live as
per-script modules under `scripts/`. There is no raw config directory to
drift from Nix.

## Hosts

- `aspire7` — the physical machine. Host-specific pieces live in
  `hosts/aspire7/`: NVIDIA PRIME bus IDs, display manager, `acer-battery`; the
  OS disk is pinned by-id in `disko.nix`. NVMe health (wear, pending sectors,
  temp) is watched by smartd (`modules/nixos/system/smartd.nix`); alerts go to
  wall, not mail — no MTA is configured. SSH is key-only with root login
  disabled (`modules/nixos/system/hardening.nix`), reachable only through the
  default-deny firewall's port 22 allowlist (`modules/nixos/system/firewall.nix`).
- `vm` — QEMU/KVM rehearsal host. Reuses the same GPT layout on `/dev/vda` to
  rehearse the installer 1:1, but skips host-specific modules (nvidia,
  acer-battery, sops).

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
`modules/home/options.nix`) — `enum [ "full" "minimal" ]`, default `full`. A
typo in a flake profile fails eval on the enum, never silently. Body gates read
`config.myProfile`. Because the module system forbids referencing `config` in
`imports` (infinite recursion), `imports` lists branch on the raw `profile`
value threaded through `specialArgs` / `home-manager.extraSpecialArgs` — the
two mechanisms never mix.

The minimal profile gates out, on the NixOS side: display manager
(`services.displayManager.ly`), gnome-keyring, NVIDIA driver + PRIME, firefox,
portal, dconf/gvfs, and the `gaming`/`virtualization` tool modules. On the
home side:
the `wayland`, `xdg`, and `scripts` categories, kitty, opencode, the dev
toolchain, GUI packages (firefox, thunar, vscodium, ...), and GTK/Qt/cursor
theming. Starship and fastfetch fall back to ASCII (no nerd glyphs, no kitty
image logo). `system.nixos.label` is `"<hostname>-<profile>"`, so systemd-boot
shows `nixos-laptop` vs `nixos-laptop-minimal`.

> [!IMPORTANT]
> The `-min` suffix is **reserved** for profile variants of an existing host —
> it is never a real hostname. `hosts/<name>-min/` must not be created;
> `install/rebuild.sh` maps `<host>-min` → `.#<host>-min`.

## Flake Inputs

- `chaotic` — nyxpkgs-unstable: bleeding-edge pkgs + binary cache. Pins own nixpkgs (cache hits); wired in via `chaotic.nixosModules.default`, no `chaotic.*` options enabled yet. Second trust root.
- `hyprland` — flake input, not nixpkgs. Pins own nixpkgs (reproducible builds + `hyprland.cachix.org`). Contributes both `nixosModules.default` and `homeManagerModules.default` (the latter imported in `users/frank/default.nix`).
- `mcp-servers-nix` — follows nixpkgs.
- `home-manager`, `sops-nix`, `disko`, `nixos-anywhere` — follow nixpkgs.
