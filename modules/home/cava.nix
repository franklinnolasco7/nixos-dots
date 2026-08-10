{ ... }:

{
  xdg.configFile."cava" = {
    source = ../../home/.config/cava;
    recursive = true;
    force = true;
  };
}
