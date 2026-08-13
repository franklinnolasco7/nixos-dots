# Host entry point for the Acer Aspire 7.
#
# This file assembles the host-specific NixOS configuration.
# hardware-configuration.nix is regenerated during installation by
# nixos-anywhere (nixos-generate-config --no-filesystems); fileSystems/swap
# come from ./disko.nix via flake.nix mkSystem.

{
  imports = [
    ./hardware-configuration.nix
    ./acer-battery.nix
    ./configuration.nix
  ];
}
