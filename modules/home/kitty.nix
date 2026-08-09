{ ... }:

{
  xdg.configFile."kitty/kitty.conf" = {
    source = ../../home/.config/kitty/kitty.conf;
    force = true;
  };
}
