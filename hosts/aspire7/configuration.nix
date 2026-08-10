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
  # Nix
  # ---------------------------------------------------------------------------

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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
  # NVIDIA PRIME (host-specific bus IDs)
  # ---------------------------------------------------------------------------

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    amdgpuBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
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
