## Flake & Home Manager

// TODO: Add Home Manager
// TODO: Configure Home Manager integration
// TODO: Configure `hosts/aspire7/configuration.nix`
// TODO: Generate and verify `hardware-configuration.nix`

## NixOS Modules

// TODO: Configure boot
// TODO: Configure networking
// TODO: Configure hardware
// TODO: Configure NVIDIA
// TODO: Configure audio
// TODO: Configure Bluetooth
// TODO: Configure users
// TODO: Configure virtualization
// TODO: Configure gaming

## Home Manager Modules

### Desktop

// TODO: Configure Hyprland
// TODO: Configure Waybar
// TODO: Configure Rofi
// TODO: Configure SwayNC

### Terminal

// TODO: Configure Zsh
// TODO: Configure Kitty
// TODO: Configure btop
// TODO: Configure Fastfetch
// TODO: Configure Starship

### Development

// TODO: Configure Git
// TODO: Configure Neovim
// TODO: Configure Node.js
// TODO: Configure Rust
// TODO: Configure Python

## Dotfiles

// TODO: Deploy `home/.config`
// TODO: Deploy `home/.local/bin`
// TODO: Deploy `.zshrc`
// TODO: Ensure shell scripts are executable
// TODO: Verify executable permissions survive a fresh installation
// TODO: Verify all configs are deployed to the correct paths

## Convert Simple Configs to Nix

// TODO: Move `.zshrc` configuration into `zsh.nix`
// TODO: Move Starship configuration into Home Manager
// TODO: Move `mimeapps.list` into `xdg.mimeApps`
// TODO: Evaluate Kitty configuration
// TODO: Evaluate btop configuration
// TODO: Evaluate Fastfetch configuration
// TODO: Evaluate htop configuration
// TODO: Evaluate Micro configuration

## Native Configs

// TODO: Keep Hyprland Lua configuration as a native config
// TODO: Keep Hyprlock configuration as a native config
// TODO: Keep Waybar JSONC/CSS as native configs
// TODO: Keep Rofi Rasi configuration as a native config
// TODO: Keep Rofi scripts
// TODO: Keep SwayNC configuration
// TODO: Keep Cava configuration
// TODO: Keep Neovim Lua configuration
// TODO: Keep Hyprctl scripts/configuration

## Themes

// TODO: Add wallpapers
// TODO: Add desktop wallpapers
// TODO: Add lockscreen wallpapers
// TODO: Add macOS-White cursor
// TODO: Add icons
// TODO: Add fonts
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

// TODO: Test automatic Disko partitioning
// TODO: Test automatic NixOS installation
// TODO: Test Home Manager activation
// TODO: Test automatic package installation
// TODO: Test automatic config deployment
// TODO: Test automatic executable permissions
// TODO: Test wallpapers
// TODO: Test cursors
// TODO: Test icons
// TODO: Test fonts

### VM Hardware Configuration

// TODO: Keep `hardware-configuration.nix` VM-specific during VM testing
// TODO: Verify `hardware-configuration.nix` uses `qemu-guest.nix` only for the VM
// TODO: Verify VM hardware modules include `virtio_pci`
// TODO: Verify VM hardware modules include `virtio_blk`
// TODO: Verify VM hardware modules include `kvm-amd`
// TODO: Keep `hardware-configuration.vm.nix` as a temporary VM-specific configuration if required
// TODO: Do not treat the VM-generated `hardware-configuration.nix` as the final physical Aspire 7 configuration
// TODO: Keep physical and VM hardware configurations separate

### Physical Aspire 7 Hardware

// TODO: Boot the real Aspire 7 from the NixOS installer
// TODO: Verify the physical NVMe device before running Disko
// TODO: Run `sudo nixos-generate-config --root /mnt` on the real Aspire 7
// TODO: Replace the VM-generated `hardware-configuration.nix` with the physical hardware configuration
// TODO: Remove VM-specific `qemu-guest.nix` configuration from the physical hardware configuration
// TODO: Remove VM-specific `virtio_pci` configuration from the physical hardware configuration
// TODO: Remove VM-specific `virtio_blk` configuration from the physical hardware configuration
// TODO: Remove VM-specific `kvm-amd` configuration if it is not generated for the physical system
// TODO: Verify physical NVMe, GPU, CPU, filesystem, and kernel modules
// TODO: Verify generated filesystem UUIDs
// TODO: Verify `/boot` configuration
// TODO: Verify swap configuration
// TODO: Commit the final physical `hardware-configuration.nix`

### Hardware Configuration Transition

// TODO: Verify current `hardware-configuration.nix` is VM-generated
// TODO: Verify `hardware-configuration.vm.nix` is only temporary
// TODO: Verify `hosts/aspire7/default.nix` imports the correct hardware configuration
// TODO: Verify Disko layout matches the physical hardware configuration
// TODO: Regenerate hardware configuration after physical Disko installation
// TODO: Verify the regenerated configuration boots successfully
// TODO: Never copy VM UUIDs into the final physical hardware configuration

## Documentation

// TODO: Write `docs/installation.md`
// TODO: Write `docs/architecture.md`
// TODO: Update `README.md`
// TODO: Document rebuilding
// TODO: Document updating
// TODO: Document rollback/recovery
// TODO: Document VM testing workflow
// TODO: Document VM vs physical hardware configuration
// TODO: Document physical Aspire 7 installation workflow

## Secrets

// TODO: Choose a secrets manager
// TODO: Configure `sops-nix` or equivalent
// TODO: Encrypt secrets
// TODO: Never commit plaintext secrets
// TODO: Remove `secrets/.gitkeep` when secrets are added

## Testing

// TODO: Test `nixos-rebuild switch --flake .#aspire7`
// TODO: Test reboot persistence
// TODO: Test rollback
// TODO: Test clean installation from scratch
// TODO: Verify all services start correctly
// TODO: Verify all applications receive their configs
// TODO: Verify scripts are executable
// TODO: Test the VM configuration independently
// TODO: Test the physical Aspire 7 configuration independently
// TODO: Verify the final physical configuration contains no VM-specific hardware settings

## Release

// TODO: Complete initial working configuration
// TODO: Clean unused files and packages
// TODO: Run formatter
// TODO: Run final installation test
// TODO: Update documentation
// TODO: Commit initial stable configuration
// TODO: Create first release/tag
