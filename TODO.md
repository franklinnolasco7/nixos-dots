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

## NixOS Modules

// DONE: Configure boot
// DONE: Configure networking
// DONE: Configure hardware
// DONE: Configure NVIDIA on physical Aspire 7
// DONE: Configure audio
// DONE: Configure Bluetooth
// DONE: Configure users
// TODO: Configure virtualization
// TODO: Configure gaming

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
// TODO: Configure Rust
// TODO: Configure Python

## Dotfiles

// TODO: Deploy `home/.config`
// TODO: Deploy `home/.local/bin`
// DONE: Deploy `.zshrc` through Home Manager
// TODO: Ensure shell scripts are executable
// TODO: Verify executable permissions survive a fresh installation
// TODO: Verify all configs are deployed to the correct paths

## Convert Simple Configs to Nix

// DONE: Integrate `.zshrc` through Home Manager
// DONE: Move Starship configuration into Home Manager
// TODO: Move `mimeapps.list` into `xdg.mimeApps`
// TODO: Evaluate Kitty configuration
// TODO: Evaluate btop configuration
// TODO: Evaluate Fastfetch configuration
// TODO: Evaluate htop configuration
// TODO: Evaluate Micro configuration

## Native Configs

// TODO: Keep Hyprland Lua configuration as a native config
// TODO: Keep Hyprlock configuration as a native config
// DONE: Keep Waybar JSONC/CSS as native configs
// DONE: Keep Rofi Rasi configuration as native config
// DONE: Keep Rofi scripts
// DONE: Keep SwayNC configuration
// TODO: Keep Cava configuration
// TODO: Keep Neovim Lua configuration
// TODO: Keep Hyprctl scripts/configuration

## Themes

// TODO: Add cursor
// TODO: Add icons
// DONE: Add fonts
// TODO: Configure shared color palette

## Development Environment

// TODO: Finish `shell.nix`
// TODO: Add `nixfmt`
// TODO: Add `stylua`
// TODO: Add `shfmt`
// TODO: Add `taplo`
// TODO: Test `nix-shell`

## Formatting

// TODO: Test `install/format.sh`
// TODO: Test `check` mode
// TODO: Test `write` mode
// TODO: Format all Nix files
// TODO: Format all Lua files
// TODO: Format all shell scripts
// TODO: Format all TOML files
// TODO: Consider migrating `shell.nix` to `devShells`

## Installation

// TODO: Implement `install/install.sh`
// TODO: Implement `install/aspire7.sh`
// TODO: Implement `install/rebuild.sh`
// TODO: Implement `install/update.sh`
// TODO: Add error handling to installation scripts
// TODO: Test installation from a fresh NixOS minimal ISO

## Disko & Fresh Installation

// DONE: Configure Disko partition layout
// DONE: Verify physical NVMe device before running Disko
// TODO: Test automatic Disko partitioning on the physical Aspire 7
// TODO: Test automatic NixOS installation
// TODO: Test Home Manager activation
// TODO: Test automatic package installation
// TODO: Test automatic config deployment
// TODO: Test automatic executable permissions
// TODO: Test wallpapers
// TODO: Test cursors
// TODO: Test icons
// TODO: Test fonts

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

// TODO: Write `docs/installation.md`
// TODO: Write `docs/architecture.md`
// TODO: Update `README.md`
// TODO: Document rebuilding
// TODO: Document updating
// TODO: Document rollback/recovery
// TODO: Document Nix/flake validation workflow
// TODO: Document physical Aspire 7 installation workflow

## Secrets

// TODO: Choose a secrets manager
// TODO: Configure `sops-nix` or equivalent
// TODO: Encrypt secrets
// TODO: Never commit plaintext secrets
// TODO: Remove `secrets/.gitkeep` when secrets are added

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
// TODO: Update documentation
// TODO: Commit initial stable configuration
// TODO: Create first release/tag
