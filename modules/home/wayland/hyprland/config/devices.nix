{ ... }:

{
  # NOTE: keyboard & touchpad enabled state is managed by toggle scripts.
  # Do NOT add enabled = true/false here or it will override the toggle
  # state on every config reload.
  wayland.windowManager.hyprland.settings.device = {
    name = "epic-mouse-v1";
    sensitivity = -0.5;
  };
}
