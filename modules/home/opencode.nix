{ ... }:

{
  xdg.configFile."opencode/config.json" = {
    source = ../../home/.config/opencode/config.json;
    force = true;
  };
}
