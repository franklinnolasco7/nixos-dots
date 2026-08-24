{ ... }:
{
  wayland.windowManager.hyprland.settings.workspace_rule = [
    {
      workspace = "special:obsidian";
      on_created_empty = "obsidian";
    }
  ];
}
