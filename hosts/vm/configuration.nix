{
  config,
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

  # Throwaway VM: no sops, so the user password is a fixed placeholder.
  # (aspire7's password is the sops-managed hash — see modules/nixos/tools/sops.nix.)
  users.users.frank.initialPassword = "123";

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
