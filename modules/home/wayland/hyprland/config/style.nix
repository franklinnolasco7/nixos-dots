{ config, lib, ... }:

let
  colors = config.lib.stylix.colors;
  rgba = c: a: "rgba(${c}${a})";

  mkCurve = name: p1: p2: {
    _args = [
      name
      {
        type = "bezier";
        points = [
          p1
          p2
        ];
      }
    ];
  };

  mkAnim =
    leaf: speed: bezier: extra:
    {
      inherit leaf speed bezier;
      enabled = true;
    }
    // extra;
in
{
  wayland.windowManager.hyprland.settings = {
    config = {
      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 2;
        col = {
          active_border = rgba colors.base0A "ee";
          inactive_border = rgba colors.base02 "ee";
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
          color = lib.mkForce "rgba(00000026)";
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
      (mkCurve "easeOutQuint"
        [
          0.23
          1
        ]
        [
          0.32
          1
        ]
      )
      (mkCurve "quick"
        [
          0.15
          0
        ]
        [
          0.1
          1
        ]
      )
      (mkCurve "linear"
        [
          0
          0
        ]
        [
          1
          1
        ]
      )
      (mkCurve "snap"
        [
          0.16
          1
        ]
        [
          0.3
          1
        ]
      )
    ];

    animation = [
      (mkAnim "global" 3 "default" { })
      (mkAnim "border" 4 "easeOutQuint" { })
      (mkAnim "windows" 2 "easeOutQuint" { })
      (mkAnim "windowsIn" 1.7 "easeOutQuint" { style = "popin 90%"; })
      (mkAnim "windowsOut" 1.5 "linear" { style = "popin 90%"; })
      (mkAnim "windowsMove" 1.5 "quick" { })
      (mkAnim "fadeIn" 2 "quick" { })
      (mkAnim "fadeOut" 2 "quick" { })
      (mkAnim "fade" 2 "quick" { })
      (mkAnim "layers" 3 "easeOutQuint" { })
      (mkAnim "layersIn" 3 "easeOutQuint" { style = "fade"; })
      (mkAnim "layersOut" 2 "linear" { style = "fade"; })
      (mkAnim "fadeLayersIn" 2 "quick" { })
      (mkAnim "fadeLayersOut" 2 "quick" { })
      (mkAnim "workspaces" 2 "easeOutQuint" { style = "fade"; })
      (mkAnim "workspacesIn" 1.5 "easeOutQuint" { style = "fade"; })
      (mkAnim "workspacesOut" 1.5 "easeOutQuint" { style = "fade"; })
      (mkAnim "zoomFactor" 7 "quick" { })
    ];
  };
}
