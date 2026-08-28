{ ... }:

{
  wayland.windowManager.hyprland.settings.layer_rule = [
    {
      name = "blur-quickshell-bar";
      match.namespace = "qs-bar";
      blur = true;
    }
  ];
}
