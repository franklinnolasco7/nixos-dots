{ config, pkgs, ... }:

{
  boot.kernelModules = [ "tcp_bbr3" ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    # CachyOS-aligned (see wiki.cachyos.org, nyx.chaotic.cx)
    "net.ipv4.tcp_congestion_control" = "bbr3";
    "vm.page-cluster" = 0;
    "kernel.nmi_watchdog" = 0;
    "net.core.netdev_max_backlog" = 65536;
  };

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "15s";
    DefaultTimeoutStopSec = "10s";
    DefaultLimitNOFILE = 1048576;
  };

  services.journald.extraConfig = "SystemMaxUse=50M";

  # CachyOS-aligned performance stack (see nyx.chaotic.cx); requires kernel ≥ 6.12.
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos_git;
  };

  services.fstrim.enable = true;

  # Allow wheel group to write CPU governor sysfs files
  services.udev.extraRules = ''
    SUBSYSTEM=="cpu", ACTION=="add", \
      RUN+="${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/chgrp wheel /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor && ${pkgs.coreutils}/bin/chmod g+w /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'"
  '';

  # Scoped passwordless sudo for swappiness only (/proc has no udev)
  # Consumer: modules/home/wayland/waybar/scripts.nix (swappiness)
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/sysctl -w vm.swappiness=*";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
