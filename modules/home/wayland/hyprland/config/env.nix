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

    # NVIDIA
    {
      _args = [
        "LIBVA_DRIVER_NAME"
        "nvidia"
      ];
    }
    {
      _args = [
        "__GLX_VENDOR_LIBRARY_NAME"
        "nvidia"
      ];
    }
    {
      _args = [
        "GBM_BACKEND"
        "nvidia-drm"
      ];
    }
    {
      _args = [
        "__NV_PRIME_RENDER_OFFLOAD"
        "1"
      ];
    }
    {
      _args = [
        "__VK_LAYER_NV_optimus"
        "NVIDIA_only"
      ];
    }
    {
      _args = [
        "NVD_BACKEND"
        "direct"
      ];
    }
    {
      _args = [
        "AQ_DRM_DEVICES"
        "/dev/dri/card1:/dev/dri/card0"
      ];
    }
    {
      _args = [
        "__GL_VRR_ALLOWED"
        "0"
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
