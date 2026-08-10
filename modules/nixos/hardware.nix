{ config, ... }:

{
  hardware.graphics.enable = true;

  services.power-profiles-daemon.enable = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [
    acer-wmi-battery
  ];

  boot.kernelModules = [
    "acer-wmi-battery"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
  };
}