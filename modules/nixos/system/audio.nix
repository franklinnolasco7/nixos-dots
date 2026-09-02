{
  config,
  lib,
  pkgs,
  ...
}:

{
  # PipeWire audio stack (NixOS 26.05 options).
  #
  # No codec/ALSA/hardware-specific settings: physical audio device
  # verification happens on the real Aspire 7.

  # RTKit hands out realtime scheduling priority to PipeWire/WirePlumber
  # threads. services.pipewire does not enable it automatically; without it
  # the audio threads run at normal priority and glitch under load.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true; # wpctl binds + pavucontrol/waybar pulseaudio modules
    wireplumber.enable = true;
  };

  # Notification sounds (swaync/pw-play) go through the BT headset (default
  # sink). WirePlumber suspends idle nodes after 3s; waking the suspended A2DP
  # transport on the first stream drops/truncates the first notification sound.
  # Keep bluez sinks running so the first play after a quiet stretch is clean.
  services.pipewire.wireplumber.extraConfig = {
    "50-bluetooth-keepalive" = {
      "monitor.bluez.rules" = [
        {
          matches = [
            { "node.name" = "~bluez_output.*"; }
          ];
          actions = {
            "update-props" = {
              "session.suspend-timeout-seconds" = 0;
            };
          };
        }
      ];
    };
  };

  # Audio power management: disable snd-hda-intel power saving on AC to prevent
  # audio cracks, restore on battery.
  # Skipped when the host declares no battery path.
  services.udev.extraRules = lib.mkIf (config.myHost.batteryPath != "") ''
    ACTION=="add", SUBSYSTEM=="sound", KERNEL=="card*", DRIVERS=="snd_hda_intel", TEST!="/run/udev/snd-hda-intel-powersave", \
        RUN+="${pkgs.bash}/bin/bash -c 'touch /run/udev/snd-hda-intel-powersave; \
            [[ $$(cat ${config.myHost.batteryPath}/status 2>/dev/null) != \"Discharging\" ]] && \
            echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave && \
            echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"

    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/bash -c 'echo $$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || \
            echo 10) > /sys/module/snd_hda_intel/parameters/power_save'"

    SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
        RUN+="${pkgs.bash}/bin/bash -c '[[ $$(cat /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && \
            echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave; \
            echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"
  '';
}
