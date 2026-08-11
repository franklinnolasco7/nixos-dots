{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/nixos
  ];

  # ---------------------------------------------------------------------------
  # Networking (host-specific; NetworkManager lives in
  # modules/nixos/networking.nix)
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-vm";

  # ---------------------------------------------------------------------------
  # Localization
  # ---------------------------------------------------------------------------

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  # frank's home profile (Hyprland HM module) enables xdg.portal; the NixOS
  # side must link the portal definitions for the HM assertion to pass.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # ---------------------------------------------------------------------------
  # State version
  # ---------------------------------------------------------------------------

  system.stateVersion = "26.05";
}
