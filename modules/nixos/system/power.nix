{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Auto-switch power profile + CPU governor on AC/battery.
  # power-profiles-daemon owns the governor; switching via powerprofilesctl
  # sets both the profile AND the governor (power-saver -> powersave,
  # performance -> performance). Direct scaling_governor writes are reverted by
  # the daemon, so we drive it through its own API.
  systemd.services.power-profile-auto = lib.mkIf (config.myHost.batteryPath != "") {
    description = "Set power profile based on power source";
    # Companion to the daemon: the daemon ships WantedBy=graphical.target and
    # After=multi-user.target, so pulling us in via the daemon's start means we
    # run after it without touching multi-user.target (ordering it there would
    # form a boot cycle: daemon -> multi-user.target -> us -> daemon).
    wantedBy = [ "power-profiles-daemon.service" ];
    after = [ "power-profiles-daemon.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    # The daemon is D-Bus activated and may not be ready the instant its unit
    # is up. Retry briefly instead of failing the oneshot on first boot.
    script = ''
      STATUS=$(cat ${config.myHost.batteryPath}/status 2>/dev/null || echo "unknown")
      PROFILE="performance"
      [[ $STATUS == "Discharging" ]] && PROFILE="power-saver"
      for i in {1..5}; do
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$PROFILE" && exit 0
        sleep 1
      done
      exit 1
    '';
  };

  # Re-trigger on plug/unplug; mirrors the POWER_SUPPLY_ONLINE pattern in audio.nix.
  services.udev.extraRules = lib.mkIf (config.myHost.batteryPath != "") ''
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", \
      RUN+="${pkgs.systemd}/bin/systemctl restart power-profile-auto"
    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", \
      RUN+="${pkgs.systemd}/bin/systemctl restart power-profile-auto"
  '';
}
