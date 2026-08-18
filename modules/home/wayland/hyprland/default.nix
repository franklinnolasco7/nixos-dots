{ ... }:

{
  imports = [ ./config ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
  };

  # Required for privileged desktop actions
  services.hyprpolkitagent.enable = true;
}
