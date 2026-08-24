{
  config,
  lib,
  pkgs,
  ...
}:

let
  scripts = import ./scripts.nix { inherit pkgs; };
  style = import ./style.nix { inherit config lib; };
in
{
  services.swaync = {
    enable = true;

    inherit style;

    settings = {
      positionX = "right";
      positionY = "top";
      cssPriority = "user";
      control-center-width = 450;
      control-center-height = 800;
      control-center-margin-top = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right = 8;
      control-center-margin-left = 0;
      fit-to-screen = true;

      notification-window-width = 400;
      notification-icon-size = 48;
      notification-body-image-height = 500;
      notification-body-image-width = 500;
      notification-inline-replies = true;
      notification-2fa-action = true;

      timeout = 5;
      timeout-low = 0;
      timeout-critical = 0;

      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;

      scripts = {
        default-sound = {
          exec = "${scripts.default-sound}/bin/swaync-default-sound";
          urgency = "Low|Normal";
        };
        critical-sound = {
          exec = "${scripts.critical-sound}/bin/swaync-critical-sound";
          urgency = "Critical";
        };
      };

      widgets = [
        "mpris"
        "volume"
      ]
      ++ lib.optionals (config.myHost.backlightDevice != "") [
        "backlight"
      ]
      ++ [
        "dnd"
        "notifications"
        "buttons-grid"
      ];

      widget-config = {
        # Hidden when the host declares no backlight device.
        backlight = lib.mkIf (config.myHost.backlightDevice != "") {
          device = config.myHost.backlightDevice;
          label = "󰃠";
          slider = true;
          min = 5;
          max = 100;
        };
        volume = {
          label = "󰕾";
          show-per-app = true;
          slider = true;
        };
        dnd = {
          text = "Do Not Disturb";
        };
        mpris = {
          image-size = 110;
          image-radius = 12;
          blur = true;
          autohide = false;
          blacklist = [
            "chromium"
            "firefox"
          ];
        };
        buttons-grid.actions = [
          {
            label = "";
            command = "swaync-client -cp && poweroff";
          }
          {
            label = "";
            command = "swaync-client -cp && reboot";
          }
          {
            label = "󰤄";
            command = "swaync-client -cp && loginctl suspend";
          }
          {
            label = "";
            command = "hyprlock";
          }
          {
            label = "󰍃";
            command = "/run/current-system/sw/bin/hyprctl dispatch 'hl.dsp.exit()'";
          }
          {
            label = "󰌐";
            type = "toggle";
            command = "toggle-laptop-kb apply \"$SWAYNC_TOGGLE_STATE\"";
            update-command = "toggle-laptop-kb status";
          }
          {
            label = "󰍾";
            type = "toggle";
            command = "toggle-laptop-tp apply \"$SWAYNC_TOGGLE_STATE\"";
            update-command = "toggle-laptop-tp status";
          }
          {
            label = "󰀝";
            type = "toggle";
            command = "airplane-mode apply \"$SWAYNC_TOGGLE_STATE\"";
            update-command = "airplane-mode status";
          }
          {
            label = "󰖂";
            type = "toggle";
            command = "vpn-toggle apply \"$SWAYNC_TOGGLE_STATE\"";
            update-command = "vpn-toggle status";
          }
          {
            label = "󱇣";
            command = "annotate-last-screenshot";
          }
        ];
      };
    };
  };
}
