{ ... }:

{
  xdg.configFile."micro" = {
    source = ../../home/.config/micro;
    recursive = true;
    force = true;
  };
}
