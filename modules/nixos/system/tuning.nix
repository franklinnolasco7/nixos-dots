{ pkgs, ... }:

{
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
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

  # sched-ext userspace scheduler (scx_rustland); requires kernel ≥ 6.12
  # (sched_ext is upstream; zen has it enabled).
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
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
