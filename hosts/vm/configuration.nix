{
  config,
  user,
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

  # Throwaway VM: initialize the user with the fixed password "123". The hash
  # is committed so no plaintext credential is stored in the user declaration.
  users.users.${user}.initialHashedPassword =
    "$6$sjcDVBzcwzGX70tZ$zASI/c5uJh2C3Xz6bVaX4bIxbkbeQ/pMD3ng6QwZa.I3gO7.edAGb4fNW08mHWx/pd3ViUldMNLBirrN6W/xC.";

  # ---------------------------------------------------------------------------
  # Display manager; ly itself is enabled by the shared desktop module
  # (modules/nixos/tools/desktop.nix); the VM only forces its session.
  # ---------------------------------------------------------------------------

  services.displayManager.ly.settings = {
    default_session = "Hyprland";
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
