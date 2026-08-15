{
  config,
  lib,
  ...
}:

let
  inline = lib.generators.mkLuaInline;
  # battery-notify only exists when the host declares a battery path.
  batteryNotify = lib.optionalString (
    config.myHost.batteryPath != ""
  ) "hl.exec_cmd(\"battery-notify &\")";
in
{
  wayland.windowManager.hyprland.settings.on = [
    {
      _args = [
        "hyprland.start"
        (inline ''
          function()
            hl.exec_cmd("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
            hl.exec_cmd("systemctl --user import-environment")
            hl.exec_cmd("wl-paste --type text --watch cliphist store")
            hl.exec_cmd("wl-paste --type image --watch cliphist store")
            hl.exec_cmd("wl-clip-persist --clipboard regular")
            -- Boot restore only; interactive changes go through the wallpaper picker (rofi/wallpaper.nix)
            hl.exec_cmd("waypaper --restore")
            hl.exec_cmd("waybar")
            ${batteryNotify}
            hl.exec_cmd("airplane-mode restore")
            hl.exec_cmd("toggle-laptop-kb restore")
            hl.exec_cmd("toggle-laptop-tp restore")
          end
        '')
      ];
    }

    # exec-always equivalent: re-run on reload
    {
      _args = [
        "config.reloaded"
        (inline ''
          function()
            hl.exec_cmd("toggle-laptop-kb restore")
            hl.exec_cmd("toggle-laptop-tp restore")
          end
        '')
      ];
    }
  ];
}
