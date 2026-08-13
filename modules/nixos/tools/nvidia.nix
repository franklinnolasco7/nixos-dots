{ pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    # CachyOS-parity driver (matches the CachyOS kernel build) — see nyx.chaotic.cx.
    package = pkgs.nvidia_cachyos;
  };
}
