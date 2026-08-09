{ ... }:

{
  xdg.configFile."starship.toml" = {
    source = ../../home/.config/starship.toml;
    force = true;
  };
}
