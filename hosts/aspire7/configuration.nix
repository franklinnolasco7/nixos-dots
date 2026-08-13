{
  config,
  lib,
  pkgs,
  user,
  profile,
  ...
}:

{
  imports = [
    ../../modules/nixos
    ../../modules/nixos/tools/sops.nix
  ]
  ++ lib.optionals (profile == "full") [
    # NVIDIA driver — GUI-only; the minimal console uses the amdgpu iGPU.
    ../../modules/nixos/tools/nvidia.nix
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

  # Distinguish boot entries in systemd-boot between the desktop and the
  # console-TTY profile (e.g. nixos-laptop vs nixos-laptop-minimal).
  system.nixos.label = "${config.networking.hostName}-${config.myProfile}";

  # ---------------------------------------------------------------------------
  # Desktop / Services
  # ---------------------------------------------------------------------------

  services.openssh.enable = true;

  services.displayManager.ly.enable = lib.mkIf (config.myProfile == "full") true;
  services.gvfs.enable = lib.mkIf (config.myProfile == "full") true;

  # User password is declarative: the sops-managed hash (user-password-hash),
  # applied on every activation. Change it by editing secrets.yaml + rebuild.
  users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password-hash.path;

  programs.dconf.enable = lib.mkIf (config.myProfile == "full") true;

  xdg.portal = lib.mkIf (config.myProfile == "full") {
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

  programs.hyprland = lib.mkIf (config.myProfile == "full") {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  # ---------------------------------------------------------------------------
  # NVIDIA PRIME (host-specific bus IDs)
  # ---------------------------------------------------------------------------

  hardware.nvidia.prime = lib.mkIf (config.myProfile == "full") {
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
  # mouse device) — see home.nix. These configure the hyprland HM module, so
  # they only exist in the full profile.
  home-manager.users.${user}.imports = lib.optionals (profile == "full") [
    ./home.nix
  ];
}
