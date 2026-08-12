{ pkgs, ... }:

{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/config.json" = {
    text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission = {
        external_directory = "ask";
      };
      mcp = { };
    };
    force = true;
  };
}
