{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/nixos
  ];

  # ---------------------------------------------------------------------------
  # Networking (host-specific; NetworkManager lives in
  # modules/nixos/networking.nix)
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-laptop";

  # ---------------------------------------------------------------------------
  # Localization
  # ---------------------------------------------------------------------------

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------------
  # Desktop / Services
  # ---------------------------------------------------------------------------

  services.displayManager.ly.enable = true;
  services.gvfs.enable = true;
  services.openssh.enable = true;

  # ---------------------------------------------------------------------------
  # Programs
  # ---------------------------------------------------------------------------

  programs.firefox.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;

    package = inputs.hyprland.packages.${pkgs.system}.hyprland;

    portalPackage =
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # ---------------------------------------------------------------------------
  # State version
  # ---------------------------------------------------------------------------

  system.stateVersion = "26.05";
}
