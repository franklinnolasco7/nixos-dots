{ ... }:

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
      border_color = "rgba(c4c4c4ee) rgba(1a1a1aee)";
    }

    {
      match = {
        float = true;
      };
      border_color = "0xff848484 0xff848484";
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
        class = "^code-oss$";
      };
      workspace = "2";
    }
    {
      match = {
        class = "^antigravity$";
      };
      workspace = "2";
    }
    {
      match = {
        class = "^cursor$";
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
      workspace = "4 silent";
    }

    {
      match = {
        class = "^Spotify$";
      };
      workspace = "6 silent";
    }
    {
      match = {
        class = "^com.rafaelmardojai.Blanket$";
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
        class = "^blender$";
      };
      opacity = "1.0 override 1.0 override 1.0 override";
    }
    {
      match = {
        class = "^gimp$";
      };
      opacity = "1.0 override 1.0 override 1.0 override";
    }
  ];
}
