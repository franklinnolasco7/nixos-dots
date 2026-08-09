{ ... }:

{
  xdg.configFile."rofi" = {
    source = ../../home/.config/rofi;
    force = true;
  };
}
