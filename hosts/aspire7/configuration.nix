{
  config,
  pkgs,
  user,
  ...
}:

{
  imports = [
    ../../modules/nixos
    ../../modules/nixos/tools/nvidia.nix
    ../../modules/nixos/tools/sops.nix
  ];

  # ---------------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------------

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7HPphkgeWcTfiMMCAmjvxnygJzylcsEB7W4AVUXv4U="
    ];
  };

  # ---------------------------------------------------------------------------
  # Networking (host-specific; NetworkManager lives in
  # modules/nixos/system/networking.nix)
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-laptop";

  # ---------------------------------------------------------------------------
  # Desktop / Services
  # ---------------------------------------------------------------------------

  services.displayManager.ly.enable = true;
  services.gvfs.enable = true;
  services.openssh.enable = true;

  programs.dconf.enable = true;

  # User password is declarative: the sops-managed hash (user-password-hash),
  # applied on every activation. Change it by editing secrets.yaml + rebuild.
  users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password-hash.path;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Programs
  # ---------------------------------------------------------------------------

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
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
    gsettings-desktop-schemas
  ];

  # Host-specific home-manager bits (NVIDIA hyprland env, laptop monitor,
  # mouse device) — see home.nix.
  home-manager.users.${user}.imports = [
    ./home.nix
  ];
}
