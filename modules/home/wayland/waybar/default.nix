{ pkgs, lib, ... }:

let
  scripts = import ./scripts.nix { inherit pkgs lib; };
  style = import ./style.nix;
in
{
  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;
        spacing = 4;

        modules-left = [
          "idle_inhibitor"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "cpu"
          "memory"
          "pulseaudio"
          "pulseaudio#microphone"
          "bluetooth"
          "network"
          "battery"
          "group/tray-expander"
          "custom/notification"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰈈";
            deactivated = "󰈉";
          };
          tooltip = true;
          tooltip-format-activated = "Idle Inhibitor: Active";
          tooltip-format-deactivated = "Idle Inhibitor: Inactive";
        };

        clock = {
          format = "{:%A %H:%M}";
          interval = 1;
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<b>{}</b>";
              days = "{}";
              weeks = "W{}";
              weekdays = "<b>{}</b>";
              today = "<span color='#c4c4c4'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        cpu = {
          format = "  {usage}%";
          tooltip-format = "<tt><b>CPU Usage: {usage}%</b> (Load: {load})\n\nCore  0: {usage0:>2}%\nCore  1: {usage1:>2}%\nCore  2: {usage2:>2}%\nCore  3: {usage3:>2}%\nCore  4: {usage4:>2}%\nCore  5: {usage5:>2}%\nCore  6: {usage6:>2}%\nCore  7: {usage7:>2}%\nCore  8: {usage8:>2}%\nCore  9: {usage9:>2}%\nCore 10: {usage10:>2}%\nCore 11: {usage11:>2}%\nCore 12: {usage12:>2}%\nCore 13: {usage13:>2}%\nCore 14: {usage14:>2}%\nCore 15: {usage15:>2}%</tt>";
          interval = 2;
          on-click-right = "kitty -e btop";
          on-click = "${scripts.cpu-governor}/bin/cpu-governor menu";
        };

        memory = {
          format = "  {percentage}%";
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G ({percentage}%)\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G";
          interval = 2;
          on-click = "${scripts.swappiness}/bin/swappiness menu";
          on-click-right = "kitty -e btop";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 MUT";
          format-icons = {
            headphone = "󰋋";
            "hands-free" = "󰋎";
            headset = "󰋎";
            phone = "󰄜";
            portable = "󰄜";
            car = "󰄋";
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          tooltip-format = "{desc}";
          on-click = "pavucontrol -t 3";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-scroll-up = "${scripts.audio-volume}/bin/audio-volume up";
          on-scroll-down = "${scripts.audio-volume}/bin/audio-volume down";
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭 MUT";
          tooltip-format = "{source_desc}";
          on-click = "pavucontrol -t 4";
          on-click-right = "pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          on-scroll-up = "${scripts.audio-microphone}/bin/audio-microphone up";
          on-scroll-down = "${scripts.audio-microphone}/bin/audio-microphone down";
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\nStatus: Enabled";
          tooltip-format-disabled = "{controller_alias}\nStatus: Disabled";
          tooltip-format-connected = "{controller_alias}\n\n{device_enumerate}";
          tooltip-format-connected-battery = "{controller_alias}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_battery_percentage}%";
          on-click = "blueman-manager";
          on-click-right = "${scripts.bluetooth-toggle}/bin/bluetooth-toggle";
        };

        network = {
          format-wifi = "󰤨  {signalStrength}%";
          format-ethernet = "  {ipaddr}";
          format-disconnected = "󰤭";
          format-disabled = "󰤭";
          tooltip-format-wifi = "{essid}\n{ipaddr}/{cidr}\n↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}\n↓ {bandwidthDownBits} ↑ {bandwidthUpBits}";
          tooltip-format-disconnected = "WiFi: Not connected";
          tooltip-format-disabled = "WiFi: Disabled";
          interval = 2;
          on-click = "kitty -e nmtui";
          on-click-right = "${scripts.wifi-toggle}/bin/wifi-toggle";
        };

        battery = {
          interval = 5;
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "{icon} {capacity}%";
          format-full = "󰁹 {capacity}%";
          format-icons = [
            "󰂃"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
          ];
          states = {
            warning = 25;
            critical = 10;
          };
          tooltip = true;
          tooltip-format = "{timeTo} ({capacity}%)";
          on-click = "${scripts.power-profile}/bin/power-profile menu";
          on-click-right = "${scripts.battery-limit-toggle}/bin/battery-limit-toggle";
        };

        "hyprland/window" = {
          format = "{class}";
          max-length = 20;
        };

        "custom/notification" = {
          tooltip = true;
          format = "{icon}";
          format-icons = {
            notification = "󰂚";
            none = "󰂛";
            dnd-notification = "󰂠";
            dnd-none = "󱏧";
            inhibited-notification = "󱅫";
            inhibited-none = "󰂛";
            dnd-inhibited-notification = "󱅫";
            dnd-inhibited-none = "󱏧";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "group/tray-expander" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 600;
          };
          modules = [
            "custom/expand-icon"
            "tray"
          ];
        };

        "custom/expand-icon" = {
          format = "";
          tooltip = false;
        };

        tray = {
          icon-size = 14;
          spacing = 4;
          show-passive-items = true;
        };
      };
    };

    style = style;
  };
}
