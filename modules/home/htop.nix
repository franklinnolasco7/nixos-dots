{ ... }:

{
  xdg.configFile."htop/htoprc" = {
    source = ../../home/.config/htop/htoprc;
    force = true;
  };
}
