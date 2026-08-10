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

  # Allow wheel group to control Acer battery charging limit
  systemd.services.acer-battery-permissions = {
    description = "Set Acer battery health_mode permissions";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      HEALTH_MODE="/sys/bus/wmi/drivers/acer-wmi-battery/health_mode"

      if [ -e "$HEALTH_MODE" ]; then
        ${pkgs.coreutils}/bin/chgrp wheel "$HEALTH_MODE"
        ${pkgs.coreutils}/bin/chmod g+w "$HEALTH_MODE"
      fi
    '';
  };

  # Allow wheel group to write CPU governor sysfs files
  services.udev.extraRules = ''
    SUBSYSTEM=="cpu", ACTION=="add", \
      RUN+="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp wheel /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor && ${pkgs.coreutils}/bin/chmod g+w /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'"
  '';

  # Scoped passwordless sudo for swappiness only (/proc has no udev)
  security.sudo.extraRules = [{
    groups = [ "wheel" ];
    commands = [
      {
        command = "/run/current-system/sw/bin/sysctl";
        options = [ "NOPASSWD" ];
      }
      {
        command = "${pkgs.procps}/bin/sysctl";
        options = [ "NOPASSWD" ];
      }
    ];
  }];
}