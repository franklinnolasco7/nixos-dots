## Flake & Home Manager

// DONE: Add Home Manager
// DONE: Configure Home Manager integration
// DONE: Configure `hosts/aspire7/default.nix`
// DONE: Finish `hosts/aspire7/configuration.nix`
// DONE: Generate and verify physical `hardware-configuration.nix`
// DONE: Configure `hosts/aspire7/disko.nix`
// DONE: Update and verify `flake.lock`
// DONE: Validate flake with `nix flake check`
// DONE: Validate NixOS system build
// DONE: Source Hyprland ecosystem from flake inputs (hyprland, hyprland-plugins, hyprland.cachix.org)
// TODO: Evaluate specific chaotic-nyx packages once needed (hyprvibr: NO, not present in chaotic-nyx package set — standalone plugin by devcexx; mesa_git for PRIME stability)

## NixOS Modules

// DONE: Configure boot
// DONE: Configure networking
// DONE: Configure hardware
// DONE: Configure NVIDIA on physical Aspire 7
// DONE: Configure audio
// DONE: Configure Bluetooth
// DONE: Configure users
// DONE: Configure virtualization
// DONE: Configure gaming

## Home Manager Modules

### Desktop

// DONE: Configure Hyprland
// DONE: Configure Waybar
// DONE: Configure Rofi
// DONE: Configure SwayNC

### Terminal

// DONE: Configure Zsh
// DONE: Configure Kitty
// DONE: Configure btop
// DONE: Configure Fastfetch
// DONE: Configure Starship

### Development

// DONE: Configure Git
// DONE: Configure Node.js
// DONE: Configure Rust
// DONE: Configure Python

## Dotfiles

// DONE: Deploy `home/.config`
// DONE: Port `home/.local/bin` scripts into `modules/home/scripts.nix`
// DONE: Deploy `.zshrc` through Home Manager
// DONE: Ensure shell scripts are executable
// DONE: Verify executable permissions survive a fresh installation
// DONE: Verify all configs are deployed to the correct paths

## Convert Simple Configs to Nix

// DONE: Integrate `.zshrc` through Home Manager
// DONE: Move Starship configuration into Home Manager
// DONE: Move `mimeapps.list` into `xdg.mimeApps`
// DONE: Evaluate Kitty configuration
// DONE: Evaluate btop configuration
// DONE: Evaluate Fastfetch configuration
// DONE: Evaluate htop configuration
// DONE: Evaluate Micro configuration

## Native Configs

// DONE: Keep Hyprland Lua configuration as a native config
// DONE: Keep Hyprlock configuration as a native config
// DONE: Keep Hypridle configuration as a native config
// DONE: Keep Waybar JSONC/CSS as native configs
// DONE: Keep Rofi Rasi configuration as native config
// DONE: Keep Rofi scripts
// DONE: Keep SwayNC configuration
// DONE: Keep Cava configuration
// TODO: Keep Neovim Lua configuration
// DONE: Keep Hyprctl scripts/configuration

## Migration: dotfiles → Home Manager

// DONE: Add cava module (xdg.configFile, source home/.config/cava)
// DONE: Add htop module (xdg.configFile, source home/.config/htop)
// DONE: Add micro module (xdg.configFile, source home/.config/micro)
// DONE: Add gtk-3.0 to repo via hm gtk module
// DONE: Add fontconfig to repo via hm fonts.fontconfig

## Themes

// DONE: Add cursor
// DONE: Add icons
// DONE: Add fonts
// DONE: Configure shared color palette

## Development Environment

// DONE: Finish `shell.nix`
// DONE: Add `nixfmt`
// DONE: Add `stylua`
// DONE: Add `shfmt`
// DONE: Add `taplo`
// DONE: Test `nix-shell`

## Formatting

// DONE: Test `install/format.sh`
// DONE: Test `check` mode
// DONE: Test `write` mode
// DONE: Format all Nix files
// DONE: Format all Lua files
// DONE: Format all shell scripts
// DONE: Format all TOML files
// DONE: Consider migrating `shell.nix` to `devShells`

## Installation

// DONE: Implement `install/install.sh` (generic multi-host installer)
// DONE: Implement `install/aspire7.sh` (thin wrapper around install.sh)
// DONE: Generalize installer to any host (hosts/<name>/default.nix + disko.nix, disko/hw-config/nixos-install parameterized)
// DONE: Declarable user per host (mkSystem { user }, users/<user>/, parameterized users.nix + sops.nix)
// DONE: Move NVIDIA module to hosts/aspire7 (shared modules are hardware-agnostic)
// DONE: Implement `install/backup-host-key.sh` (sops identity backup pre-wipe, USB auto-detect + select)
// DONE: Pin Disko via flake + use `--mode destroy,format,mount` in installer
// DONE: Regenerate `hardware-configuration.nix` during install (stale UUIDs → no boot)
// DONE: Restore SSH host key into `/mnt/etc/ssh` before `nixos-install` (sops activation)
// DONE: Register user age key as second sops activation identity
// DONE: Implement `install/rebuild.sh`
// DONE: Implement `install/update.sh`
// DONE: Add error handling to installation scripts
// DONE: Add hosts/vm rehearsal host + install/run-vm.sh (QEMU/KVM + OVMF, disko/install rehearsal without real hardware)
// TODO: Test installation from a fresh NixOS minimal ISO

## Disko & Fresh Installation

// DONE: Configure Disko partition layout
// DONE: Verify physical NVMe device before running Disko
// TODO: Test automatic Disko partitioning on the physical Aspire 7
// TODO: Test automatic NixOS installation
// DONE: Test Home Manager activation
// DONE: Test automatic package installation
// DONE: Test automatic config deployment
// DONE: Test automatic executable permissions
// DONE: Test wallpapers
// DONE: Test cursors
// DONE: Test icons
// DONE: Test fonts

## Physical Aspire 7 Hardware

// DONE: Boot the real Aspire 7 from the NixOS installer
// DONE: Verify the physical NVMe device before running Disko
// DONE: Run `nixos-generate-config --root /mnt` on the real Aspire 7
// DONE: Add generated physical `hardware-configuration.nix` to the repository
// DONE: Verify physical NVMe, GPU, CPU, filesystem, and kernel modules
// DONE: Verify generated filesystem UUIDs
// DONE: Verify `/boot` configuration
// DONE: Verify swap configuration
// DONE: Verify generated hardware configuration does not contain VM-specific settings
// DONE: Commit the final physical `hardware-configuration.nix`

## Hardware Configuration

// DONE: Generate physical `hardware-configuration.nix` during installation
// DONE: Verify `hosts/aspire7/default.nix` imports the generated hardware configuration
// DONE: Verify Disko layout matches the physical hardware configuration
// DONE: Verify physical filesystem UUIDs
// DONE: Verify the regenerated configuration boots successfully
// DONE: Never copy VM UUIDs into the final physical hardware configuration

## Documentation

// DONE: Write `docs/installation.md`
// DONE: Write `docs/architecture.md`
// DONE: Update `README.md`
// DONE: Document rebuilding
// DONE: Document updating
// DONE: Document rollback/recovery
// DONE: Document Nix/flake validation workflow
// DONE: Document physical Aspire 7 installation workflow

## Secrets

// DONE: Choose a secrets manager (sops-nix + age via ssh key)
// DONE: Configure `sops-nix`
// DONE: Encrypt secrets (run `bash install/init-secrets.sh` on the NixOS machine)
// DONE: Never commit plaintext secrets
// DONE: Remove `secrets/.gitkeep`
// DONE: Register user age key (`~/.config/sops/age/keys.txt`) for passwordless editing
// DONE: Re-encrypt `secrets/secrets.yaml` to host + user key
// DONE: Rewrite `docs/secrets.md`
// DONE: Rotate context7 + GitHub tokens (both were pasted in chat during setup)

## Testing

// DONE: Test `nix flake lock` in the VM
// DONE: Test `nix flake check` in the VM
// DONE: Test NixOS system build in the VM
// DONE: Test `nixos-rebuild switch --flake .#aspire7`
// TODO: Test reboot persistence
// TODO: Test rollback
// TODO: Test clean installation from scratch
// TODO: Verify all services start correctly
// TODO: Verify all applications receive their configs
// TODO: Verify scripts are executable
// TODO: Verify the final physical configuration contains no VM-specific hardware settings

## Release

// TODO: Complete initial working configuration
// TODO: Clean unused files and packages
// TODO: Run formatter
// TODO: Run final installation test
// DONE: Update documentation
// TODO: Commit initial stable configuration
// TODO: Create first release/tag

## TO DO PRIO (things to do while im testing)

// DONE: Fix waybar cpu governor and swappiness on rofi options not working (need sudo)
// DONE: Fix waybar scroll on modules to adjust volumes of mic or audio not working
// DONE: Fix waybar battery when left clicking the battery limit script also need sudo
// DONE: Fix Rofi emoji for drun not displaying properly
// DONE: rofi wallpaper selector aint showing any images
// DONE: opencode not installed
