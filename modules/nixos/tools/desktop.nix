# Shared desktop stack, imported only in the full profile (tools/default.nix),
# so no myProfile gates here. Host-specific bits (ly session selection, PRIME
# bus IDs) stay in hosts/<host>/configuration.nix.
{ pkgs, ... }:

{
  services.displayManager.ly.enable = true;
  services.gvfs.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];

    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # gsr-kms-server setcap wrapper: `-w screen` recording on Wayland talks to
  # DRM directly, which needs cap_sys_admin or every recording prompts for
  # root (the wrapper is the sanctioned upstream mechanism).
  programs.gpu-screen-recorder.enable = true;
}
