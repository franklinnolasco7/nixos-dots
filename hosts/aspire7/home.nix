{ ... }:

{
  # Host-specific hyprland settings for the physical laptop. Shared modules
  # (modules/home/wayland/hyprland) stay hardware-agnostic; NVIDIA PRIME env,
  # the laptop monitor and the mouse live here. Imported via
  # `home-manager.users.<user>.imports` in configuration.nix.

  wayland.windowManager.hyprland.settings = {
    # NVIDIA PRIME
    env = [
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
    ];

    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };

    monitor = {
      output = "eDP-1";
      mode = "1920x1080@60";
      position = "0x0";
      scale = 1;
    };
  };
}
