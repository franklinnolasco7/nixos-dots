{ config, pkgs, ... }:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [
    acer-wmi-battery
  ];

  boot.kernelModules = [
    "acer-wmi-battery"
  ];

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
}