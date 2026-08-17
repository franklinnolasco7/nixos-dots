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

  # Host hardware defaults consumed by shared modules
  # (modules/nixos/options.nix).
  myHost.batteryPath = "/sys/class/power_supply/BAT1";

  # ---------------------------------------------------------------------------
  # Kernel (host-specific; Chaotic-Nyx CachyOS build — see nyx.chaotic.cx)
  # ---------------------------------------------------------------------------

  # CachyOS kernel with kconfig parity to upstream; uses the nyx binary cache.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # ---------------------------------------------------------------------------
  # Nix
  # ---------------------------------------------------------------------------

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
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
  # Services
  # ---------------------------------------------------------------------------

  services.openssh.enable = true;

  # User password is declarative: the sops-managed hash (user-password-hash),
  # applied on every activation. Change it by editing secrets.yaml + rebuild.
  users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password-hash.path;

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
