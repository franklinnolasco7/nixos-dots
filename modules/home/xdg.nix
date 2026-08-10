{ ... }:

{
  xdg.configFile."mimeapps.list" = {
    source = ../../home/.config/mimeapps.list;
    force = true;
  };
}
