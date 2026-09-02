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
    ../../modules/nixos/tools/wireguard.nix
  ]
  ++ lib.optionals (profile == "full") [
    # NVIDIA driver; GUI-only; the minimal console uses the amdgpu iGPU.
    ../../modules/nixos/tools/nvidia.nix
  ];

  # Host hardware defaults consumed by shared modules
  # (modules/nixos/options.nix).
  myHost.batteryPath = "/sys/class/power_supply/BAT1";

  # ---------------------------------------------------------------------------
  # Persistent /home (bind mount from the LUKS partition). Root / stays
  # tmpfs/impermanent; /home is a standard fstab mount with no impermanence
  # involvement. Merges alongside the disko-derived fileSystems.
  # ---------------------------------------------------------------------------

  fileSystems."/home" = {
    device = "/nix/home";
    fsType = "none";
    options = [ "bind" ];
    depends = [ "/nix" ];
  };

  # ---------------------------------------------------------------------------
  # Kernel (zen-linux; EEVDF, sched-ext, ntsync built in; cached on
  # cache.nixos.org)
  # ---------------------------------------------------------------------------

  boot.kernelPackages = pkgs.linuxPackages_zen;

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

  # Bootstrap local login for direct nixos-install runs. install.sh replaces
  # this before first reboot; with mutableUsers, later passwd changes persist.
  # Hash of "123" (yescrypt would also work; this existing SHA-512 hash is
  # retained only as a short-lived bootstrap credential).
  users.users.${user}.initialHashedPassword =
    "$6$sjcDVBzcwzGX70tZ$zASI/c5uJh2C3Xz6bVaX4bIxbkbeQ/pMD3ng6QwZa.I3gO7.edAGb4fNW08mHWx/pd3ViUldMNLBirrN6W/xC.";

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
  # mouse device); see home.nix. These configure the hyprland HM module, so
  # they only exist in the full profile.
  home-manager.users.${user}.imports = lib.optionals (profile == "full") [
    ./home.nix
  ];
}
