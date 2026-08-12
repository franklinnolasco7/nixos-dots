{ ... }:

let
  colors = import ../../../styling/palette.nix;
  rgba = c: a: "rgba(${c}${a})";
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        col = {
          active_border = rgba (builtins.substring 1 6 colors.borderActive) "ee";
          inactive_border = rgba (builtins.substring 1 6 colors.borderInactive) "ee";
        };
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
        snap = {
          enabled = true;
          window_gap = 10;
          monitor_gap = 10;
        };
      };

      decoration = {
        rounding = 0;
        active_opacity = 0.95;
        inactive_opacity = 0.85;
        fullscreen_opacity = 1.0;
        shadow = {
          enabled = false;
          range = 8;
          render_power = 2;
          color = "rgba(00000026)";
        };
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          ignore_opacity = true;
          noise = 0.08;
          contrast = 1.5;
          brightness = 0.8;
          xray = false;
        };
      };

      animations = {
        enabled = true;
      };
    };

    curve = [
      {
        _args = [
          "easeOutQuint"
          {
            type = "bezier";
            points = [
              [
                0.23
                1
              ]
              [
                0.32
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "quick"
          {
            type = "bezier";
            points = [
              [
                0.15
                0
              ]
              [
                0.1
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "linear"
          {
            type = "bezier";
            points = [
              [
                0
                0
              ]
              [
                1
                1
              ]
            ];
          }
        ];
      }
      {
        _args = [
          "snap"
          {
            type = "bezier";
            points = [
              [
                0.16
                1
              ]
              [
                0.3
                1
              ]
            ];
          }
        ];
      }
    ];

    animation = [
      {
        leaf = "global";
        enabled = true;
        speed = 3;
        bezier = "default";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 4;
        bezier = "easeOutQuint";
      }
      {
        leaf = "windows";
        enabled = true;
        speed = 2;
        bezier = "easeOutQuint";
      }
      {
        leaf = "windowsIn";
        enabled = true;
        speed = 1.7;
        bezier = "easeOutQuint";
        style = "popin 90%";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 1.5;
        bezier = "linear";
        style = "popin 90%";
      }
      {
        leaf = "windowsMove";
        enabled = true;
        speed = 1.5;
        bezier = "quick";
      }
      {
        leaf = "fadeIn";
        enabled = true;
        speed = 2;
        bezier = "quick";
      }
      {
        leaf = "fadeOut";
        enabled = true;
        speed = 2;
        bezier = "quick";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 2;
        bezier = "quick";
      }
      {
        leaf = "layers";
        enabled = true;
        speed = 3;
        bezier = "easeOutQuint";
      }
      {
        leaf = "layersIn";
        enabled = true;
        speed = 3;
        bezier = "easeOutQuint";
        style = "fade";
      }
      {
        leaf = "layersOut";
        enabled = true;
        speed = 2;
        bezier = "linear";
        style = "fade";
      }
      {
        leaf = "fadeLayersIn";
        enabled = true;
        speed = 2;
        bezier = "quick";
      }
      {
        leaf = "fadeLayersOut";
        enabled = true;
        speed = 2;
        bezier = "quick";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 2;
        bezier = "easeOutQuint";
        style = "fade";
      }
      {
        leaf = "workspacesIn";
        enabled = true;
        speed = 1.5;
        bezier = "easeOutQuint";
        style = "fade";
      }
      {
        leaf = "workspacesOut";
        enabled = true;
        speed = 1.5;
        bezier = "easeOutQuint";
        style = "fade";
      }
      {
        leaf = "zoomFactor";
        enabled = true;
        speed = 7;
        bezier = "quick";
      }
    ];
  };
}
