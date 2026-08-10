{ ... }:

{
  xdg.configFile."btop/btop.conf" = {
    source = ../../home/.config/btop/btop.conf;
    force = true;
  };
}
