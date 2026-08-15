{ ... }:

{
  imports = [ ./config ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
  };
}
