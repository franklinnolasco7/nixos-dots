{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors;
in
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
        color = lib.mkForce "rgba(${colors.base00}ff)";
      };

      input-field = {
        monitor = "";
        size = "420, 62";
        rounding = 0;
        outline_thickness = 2;
        dots_size = 0.4;
        dots_spacing = 0.2;
        dots_center = true;
        outer_color = lib.mkForce "rgba(${colors.base02}ff)";
        inner_color = lib.mkForce "rgba(${colors.base01}ff)";
        font_color = lib.mkForce "rgba(${colors.base08}ff)";
        capslock_color = lib.mkForce "rgba(${colors.base0A}ff)";
        fade_on_empty = true;
        check_color = lib.mkForce "rgba(${colors.base04}ff)";
        fail_color = lib.mkForce "rgba(${colors.base0A}ff)";
        fail_text = "<span foreground=\"##${colors.base0A}\">Incorrect password</span>";
        placeholder_text = "<span foreground=\"##${colors.base04}\">Enter password</span>";
        position = "0, -40";
        halign = "center";
        valign = "center";
      };

      label = [
        {
          monitor = "";
          text = "$TIME";
          color = lib.mkForce "rgba(${colors.base0A}ff)";
          font_family = lib.mkForce "Inter";
          font_size = 78;
          position = "0, 105";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] echo \"<span foreground='#${colors.base04}'>$(date +\"%A  %d %B  %Y\")</span>\"";
          color = lib.mkForce "rgba(${colors.base04}ff)";
          font_family = lib.mkForce "Inter";
          font_size = 14;
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
