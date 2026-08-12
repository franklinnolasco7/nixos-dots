{ ... }:

{
  imports = [
    ../../modules/nixos
  ];

  # ---------------------------------------------------------------------------
  # Networking (host-specific; NetworkManager lives in
  # modules/nixos/system/networking.nix)
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-vm";

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  # frank's home profile (Hyprland HM module) enables xdg.portal; the NixOS
  # side must link the portal definitions for the HM assertion to pass.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

}
