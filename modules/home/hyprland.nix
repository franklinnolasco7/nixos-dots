{ pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [
      # Example plugin:
      # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprbars
    ];
  };

  programs.hyprlock = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprlock;
  };

  services.hypridle = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hypridle;
  };

  xdg.configFile."hypr/hyprland.lua" = {
    source = ../../home/.config/hypr/hyprland.lua;
    force = true;
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
