{ pkgs, ... }:

{
  imports = [ ./config ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    configType = "lua";
  };
}
