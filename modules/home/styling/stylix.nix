{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  stylix = lib.mkIf (config.myProfile == "full") {
    targets = {
      hyprland.enable = true;
      hyprpaper.enable = false;
      waybar.enable = false;
      rofi.enable = true;
      swaync.enable = false;
      gtk = {
        enable = false;
        extraCss = ''
          @import url("${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css");
        '';
      };
      qt.enable = false;
      hyprlock.enable = false;
      firefox = {
        enable = true;
        profileNames = [ "83kzxfus.default" ];
      };
      kitty.enable = false;
      btop.enable = false;
      cava.enable = false;
      starship.enable = false;
    };
  };

  home.pointerCursor.hyprcursor.enable = lib.mkIf (config.myProfile == "full") true;
}
