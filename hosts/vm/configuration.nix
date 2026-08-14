{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/nixos
  ];

  # ---------------------------------------------------------------------------
  # Networking (host-specific; NetworkManager lives in
  # modules/nixos/system/networking.nix)
  # ---------------------------------------------------------------------------

  networking.hostName = "nixos-vm";

  # Distinguish boot entries in systemd-boot between the desktop and the
  # console-TTY profile (e.g. nixos-vm vs nixos-vm-minimal).
  system.nixos.label = "${config.networking.hostName}-${config.myProfile}";

  # Throwaway VM: no sops, so the user password is a fixed placeholder. The
  # hash of "123" is committed so no plaintext credential sits in the repo.
  # (aspire7's password is the sops-managed hash — see modules/nixos/tools/sops.nix.)
  users.users.frank.initialHashedPassword = "$6$sjcDVBzcwzGX70tZ$zASI/c5uJh2C3Xz6bVaX4bIxbkbeQ/pMD3ng6QwZa.I3gO7.edAGb4fNW08mHWx/pd3ViUldMNLBirrN6W/xC.";

  # ---------------------------------------------------------------------------
  # Desktop / Services (full profile only — the minimal variant stays on the
  # console TTY, mirroring hosts/aspire7/configuration.nix)
  # ---------------------------------------------------------------------------

  services.displayManager.ly.enable = lib.mkIf (config.myProfile == "full") true;
  services.displayManager.ly.settings = lib.mkIf (config.myProfile == "full") {
    default_session = "Hyprland";
  };
  services.gvfs.enable = lib.mkIf (config.myProfile == "full") true;

  programs.dconf.enable = lib.mkIf (config.myProfile == "full") true;

  xdg.portal = lib.mkIf (config.myProfile == "full") {
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

  programs.hyprland = lib.mkIf (config.myProfile == "full") {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
  };

  # ---------------------------------------------------------------------------
  # System packages
  # ---------------------------------------------------------------------------

  # frank's home profile (Hyprland HM module) enables xdg.portal; the NixOS
  # side must link the portal definitions for the HM assertion to pass.
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

}
