{ pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    extraConfig = builtins.readFile ../../home/.config/hypr/hyprland.lua;
  };

  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
  };

  services.hypridle = {
    enable = true;
    package = pkgs.hypridle;
  };

  xdg.configFile."hypr/hyprlock.conf" = {
    source = ../../home/.config/hypr/hyprlock.conf;
    force = true;
  };

  xdg.configFile."hypr/hypridle.conf" = {
    source = ../../home/.config/hypr/hypridle.conf;
    force = true;
  };
}
