{ pkgs, ... }:

{
  boot = {
    kernelModules = [ "tcp_bbr3" ];

    kernel.sysctl = {
      "vm.swappiness" = 180;
      # CachyOS-aligned (see wiki.cachyos.org, nyx.chaotic.cx)
      "net.ipv4.tcp_congestion_control" = "bbr3";
      "vm.page-cluster" = 0;
      # Keep more page cache (dentries/inodes) resident instead of recycling it.
      "vm.vfs_cache_pressure" = 50;
      # Cap writeback burst size (CachyOS values): a smaller background limit
      # smooths NVMe write spikes under load instead of one big stall on flush.
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_writeback_centisecs" = 1500;
      "kernel.nmi_watchdog" = 0;
      "net.core.netdev_max_backlog" = 65536;
    };
  };

  # Watchdog timers are unused (nmi_watchdog disabled above); blacklist so they
  # never grab the hardware timer. sp5100_tco is the AMD one (Ryzen), iTCO the Intel.
  boot.blacklistedKernelModules = [
    "iTCO_wdt"
    "sp5100_tco"
  ];

  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "15s";
    DefaultTimeoutStopSec = "10s";
    DefaultLimitNOFILE = 1048576;
  };

  services.journald.extraConfig = "SystemMaxUse=50M";

  # sched-ext userspace scheduler (scx_rustland); requires kernel ≥ 6.12
  # (sched_ext is upstream; the cachyos kernel has it enabled).
  services.scx = {
    enable = true;
    scheduler = "scx_rustland";
  };

  services.fstrim.enable = true;

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

  # Allow wheel to switch/hold power profiles; ly doesn't mark Hyprland active
  # Consumer: modules/home/wayland/waybar/scripts.nix (power-profile)
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (
        subject.isInGroup("wheel") &&
        (action.id == "org.freedesktop.UPower.PowerProfiles.switch-profile" ||
          action.id == "org.freedesktop.UPower.PowerProfiles.hold-profile")
      ) {
        return polkit.Result.YES;
      }
    });
  '';
}
