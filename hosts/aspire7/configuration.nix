{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ---------------------------------------------------------------------------
  # Networking
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;

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
  # User
  # ---------------------------------------------------------------------------

  users.users.frank = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      tree
      git
      kitty
      neovim
      rofi
      thunar
      waybar
      micro
      swaybg
      fastfetch
      btop
      vscodium
      chromium
    ];
  };

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
