{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
    size = 24;
    gtk.enable = true;
    hyprcursor.enable = true;
  };
}
