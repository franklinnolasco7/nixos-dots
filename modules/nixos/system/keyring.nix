{
  config,
  lib,
  ...
}:
{
  # Desktop secret plumbing: unlocks the keyring on ly login, which also
  # starts the ssh component (daemon default: pkcs11,secrets,ssh), so git's
  # ssh-signing passphrase is cached once per login instead of per op.
  services.gnome.gnome-keyring.enable = lib.mkIf (config.myProfile == "full") true;
  security.pam.services.ly.enableGnomeKeyring = lib.mkIf (config.myProfile == "full") true;
}
