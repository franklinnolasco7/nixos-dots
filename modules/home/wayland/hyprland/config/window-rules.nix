{ config, ... }:
let
  colors = config.myPalette;
  rgba = c: a: "rgba(${c}${a})";
in
{
  wayland.windowManager.hyprland.settings.window_rule = [
    {
      name = "suppress-maximize";
      match = {
        class = ".*";
      };
      suppress_event = "maximize";
    }
    # Fix XWayland dragging issues
    {
      name = "fix-xwayland-drags";
      match = {
        xwayland = true;
        float = true;
        fullscreen = false;
        pin = false;
      };
      no_initial_focus = true;
    }
    {
      match = {
        float = false;
      };
      border_color = "${rgba colors.base0D "ee"} ${rgba colors.base01 "ee"}";
    }
    {
      match = {
        float = true;
        focus = true;
      };
      border_color = "${rgba colors.base07 "ee"} ${rgba colors.base07 "ee"}";
    }
    {
      match = {
        float = true;
        focus = false;
      };
      border_color = "${rgba colors.base03 "ee"} ${rgba colors.base03 "ee"}";
    }
    {
      match = {
        class = "^firefox$";
      };
      workspace = "1";
      opacity = "1.0 override 1.0 override 1.0 override";
    }
    {
      match = {
        class = "^codium$";
      };
      workspace = "2";
    }
    {
      match = {
        class = "^steam$";
      };
      workspace = "3 silent";
    }
    {
      match = {
        class = "^steam_app_[0-9]+$";
      };
      immediate = true;
      opacity = "1.0 override 1.0 override 1.0 override";
    }
    {
      match = {
        class = "^vesktop$";
      };
      workspace = "5 silent";
    }
    {
      match = {
        class = "^md.Obsidian$";
      };
      workspace = "special:obsidian";
      float = true;
      size = [
        "(monitor_w*0.8)"
        "(monitor_h*0.8)"
      ];
      center = true;
    }
    {
      match = {
        class = "^Spotify$";
      };
      workspace = "6 silent";
    }
    {
      match = {
        class = "^org.gnome.gThumb$";
      };
      size = [
        1400
        900
      ];
      float = true;
      center = true;
    }
    {
      match = {
        class = "^com.gabm.satty$";
      };
      size = [
        1400
        900
      ];
      float = true;
      center = true;
    }
    {
      match = {
        title = "^Picture-in-Picture$";
      };
      float = true;
      pin = true;
    }
    {
      match = {
        class = "^gimp$";
      };
      opacity = "1.0 override 1.0 override 1.0 override";
    }
  ];
}
