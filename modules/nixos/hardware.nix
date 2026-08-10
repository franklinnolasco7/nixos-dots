{
  hardware.graphics.enable = true;
  services.power-profiles-daemon.enable = true;
  boot.kernelModules = [ "acer-wmi-battery" ];
  boot.kernel.sysctl = { "vm.swappiness" = 180; };
}
