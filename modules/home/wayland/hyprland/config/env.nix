{ ... }:

{
  wayland.windowManager.hyprland.settings.env = [
    # Cursor
    {
      _args = [
        "XCURSOR_SIZE"
        "24"
      ];
    }
    {
      _args = [
        "HYPRCURSOR_SIZE"
        "24"
      ];
    }
    {
      _args = [
        "XCURSOR_THEME"
        "macOS"
      ];
    }

    # Qt
    {
      _args = [
        "QT_QPA_PLATFORMTHEME"
        "qt5ct"
      ];
    }
    {
      _args = [
        "QT_SCALE_FACTOR"
        "1"
      ];
    }
    {
      _args = [
        "QT_QPA_PLATFORM"
        "wayland;xcb"
      ];
    }
    {
      _args = [
        "QT_AUTO_SCREEN_SCALE_FACTOR"
        "1"
      ];
    }
    {
      _args = [
        "QT_WAYLAND_DISABLE_WINDOWDECORATION"
        "1"
      ];
    }

    # Wayland
    {
      _args = [
        "XDG_SESSION_TYPE"
        "wayland"
      ];
    }
    {
      _args = [
        "ELECTRON_OZONE_PLATFORM_HINT"
        "auto"
      ];
    }

    # GTK
    {
      _args = [
        "GDK_SCALE"
        "1"
      ];
    }
    {
      _args = [
        "GDK_DPI_SCALE"
        "1"
      ];
    }
  ];
}
