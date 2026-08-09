{ ... }:

{
  xdg.configFile."swaync" = {
    source = ../../home/.config/swaync;
    force = true;
  };
}
