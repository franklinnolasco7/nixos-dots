{ ... }:

{
  xdg.configFile."hyprctl" = {
    source = ../../home/.config/hyprctl;
    recursive = true;
    force = true;
  };
}
