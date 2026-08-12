{ ... }:

{
  wayland.windowManager.hyprland.settings.window_rule = [
    # Ignore maximize requests from apps
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

    # Border for tiled windows
    {
      match = {
        float = false;
      };
      border_color = "rgba(c4c4c4ee) rgba(1a1a1aee)";
    }

    # Border for floating windows
    {
      match = {
        float = true;
      };
      border_color = "0xff848484 0xff848484";
    }

    # Firefox
    {
      match = {
        class = "^firefox$";
      };
      workspace = "1";
      opacity = "1.0 override 1.0 override 1.0 override";
    }

    # Editors / IDE
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

    # Steam
    {
      match = {
        class = "^steam$";
      };
      workspace = "3 silent";
    }

    # Steam game windows
    {
      match = {
        class = "^steam_app_[0-9]+$";
      };
      immediate = true;
      opacity = "1.0 override 1.0 override 1.0 override";
    }

    # Discord (Vesktop)
    {
      match = {
        class = "^vesktop$";
      };
      workspace = "5 silent";
    }

    # Obsidian
    {
      match = {
        class = "^md.Obsidian$";
      };
      workspace = "4 silent";
    }

    # Spotify / Blanket
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

    # gThumb
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

    # Satty
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

    # Picture in Picture
    {
      match = {
        title = "^Picture-in-Picture$";
      };
      float = true;
      pin = true;
    }

    # Always opaque
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
