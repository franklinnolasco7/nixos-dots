# Host entry point for the Acer Aspire 7.
#
# This file assembles the host-specific NixOS configuration.
# hardware-configuration.nix is generated automatically during
# installation with nixos-generate-config.

{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
