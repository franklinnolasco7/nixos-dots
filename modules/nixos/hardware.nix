{ config, pkgs, ... }:

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

  # Allow wheel group to write battery health_mode and cpu governor sysfs
  # directly — no sudo needed in waybar scripts
  services.udev.extraRules = ''
    SUBSYSTEM=="wmi", DRIVER=="acer-wmi-battery", \
      RUN+="${pkgs.coreutils}/bin/chgrp wheel /sys/bus/wmi/drivers/acer-wmi-battery/health_mode", \
      RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/bus/wmi/drivers/acer-wmi-battery/health_mode"

    SUBSYSTEM=="cpu", ACTION=="add", \
      RUN+="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp wheel /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor && ${pkgs.coreutils}/bin/chmod g+w /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'"
  '';

  # Scoped passwordless sudo for swappiness only (/proc has no udev)
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [{
      command = "${pkgs.procps}/bin/sysctl -w vm.swappiness=*";
      options = [ "NOPASSWD" ];
    }];
  }];
}