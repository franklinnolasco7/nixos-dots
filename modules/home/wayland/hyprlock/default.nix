{ pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;

    settings = {
      general = {
        screencopy_mode = 1;
        hide_cursor = false;
        ignore_empty_input = true;
      };

      animation = "fade, 0";

      background = {
        monitor = "";
        color = "rgba(080808ff)";
      };

      input-field = {
        monitor = "";
        size = "420, 62";
        rounding = 0;
        outline_thickness = 2;
        dots_size = 0.4;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = "rgba(1a1a1aff)";
        inner_color = "rgba(121212ff)";
        font_color = "rgba(a6a6a6ff)";
        capslock_color = "rgba(e0e0e0ff)";
        fade_on_empty = true;
        check_color = "rgba(848484ff)";
        fail_color = "rgba(e0e0e0ff)";
        fail_text = "<span foreground=\"##e0e0e0\">Incorrect password</span>";
        placeholder_text = "<span foreground=\"##5c5c5c\">Enter password</span>";
        position = "0, -40";
        halign = "center";
        valign = "center";
      };

      label = [
        {
          monitor = "";
          text = "$TIME";
          color = "rgba(c4c4c4ff)";
          font_family = "Inter";
          font_size = 78;
          position = "0, 105";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] echo \"<span foreground='#5c5c5c'>$(date +\"%A  %d %B  %Y\")</span>\"";
          color = "rgba(5c5c5cff)";
          font_family = "Inter";
          font_size = 14;
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
