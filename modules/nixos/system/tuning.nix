{ config, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
  };

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
