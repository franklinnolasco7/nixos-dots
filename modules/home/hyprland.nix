{ ... }:

{
  xdg.configFile."hypr/hyprland.lua" = {
    source = ../../home/.config/hypr/hyprland.lua;
    force = true;
  };

  xdg.configFile."hypr/hyprlock.conf" = {
    source = ../../home/.config/hypr/hyprlock.conf;
    force = true;
  };
}
