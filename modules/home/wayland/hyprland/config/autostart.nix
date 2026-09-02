{
  config,
  lib,
  ...
}:

let
  inline = lib.generators.mkLuaInline;

  mkFnBody =
    cmds:
    ''
      function()
    ''
    + lib.concatMapStringsSep "\n" (c: ''hl.exec_cmd("${c}")'') cmds
    + ''

      end
    '';

  mkOnEvent = event: cmds: {
    _args = [
      event
      (inline (mkFnBody cmds))
    ];
  };

  restoreCmds = [
    "toggle-laptop-kb restore"
    "toggle-laptop-tp restore"
  ];

  startupCmds = [
    "dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    "systemctl --user import-environment"
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    "wl-clip-persist --clipboard regular"
    # Restore the last wallpaper picked via rofi (written by
    # modules/home/wayland/rofi/wallpaper.nix). awww already owns the daemon.
    "$([ -f ~/.cache/rofi-wallpaper/last ] && xargs -r awww img < ~/.cache/rofi-wallpaper/last)"
    "waybar"
    "gsr start"
  ]
  ++ lib.optional (config.myHost.batteryPath != "") "battery-notify &"
  ++ [ "airplane-mode restore" ]
  ++ restoreCmds;
in
{
  wayland.windowManager.hyprland.settings.on = [
    (mkOnEvent "hyprland.start" startupCmds)
    (mkOnEvent "config.reloaded" restoreCmds)
  ];
}
