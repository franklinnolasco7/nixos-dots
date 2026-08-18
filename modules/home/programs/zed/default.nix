{
  pkgs,
  ...
}:

let
  json = pkgs.formats.json { };
in
{
  home.packages = [ pkgs.zed-editor ];

  xdg.configFile."zed/settings.json".source = json.generate "zed-settings" {
    project_panel.dock = "right";
    outline_panel.dock = "right";
    collaboration_panel.dock = "right";
    git_panel.dock = "right";
    agent = {
      dock = "left";
      default_model = {
        provider = "zed.dev";
        model = "gpt-5.6-sol";
        enable_thinking = true;
        effort = "medium";
      };
      favorite_models = [ ];
      model_parameters = [ ];
    };
    agent_servers = {
      cursor.type = "registry";
      claude-acp.type = "registry";
      codex-acp.type = "registry";
      github-copilot-cli.type = "registry";
    };
    base_keymap = "Zed";
    icon_theme = "Zed (Default)";
    ui_font_size = 16;
    buffer_font_size = 15;
    theme = {
      mode = "dark";
      light = "Ayu Light";
      dark = "Ayu Dark";
    };
  };
}
