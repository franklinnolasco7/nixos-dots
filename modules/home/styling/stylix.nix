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
      gtk.enable = true;
      qt.enable = true;
      hyprlock.enable = false;
      firefox = {
        enable = true;
        profileNames = [ "83kzxfus.default" ];
      };
      kitty.enable = true;
      btop.enable = true;
      cava.enable = false;
      starship.enable = true;
    };
  };

  home.pointerCursor.hyprcursor.enable = lib.mkIf (config.myProfile == "full") true;
}
