{
  config,
  lib,
  ...
}:
{
  # Desktop secret plumbing: unlocks the keyring on ly login, which also
  # starts the ssh component (daemon default: pkcs11,secrets,ssh), so git's
  # ssh-signing passphrase is cached once per login instead of per op.
  config = lib.mkIf (config.myProfile == "full") {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.ly.enableGnomeKeyring = true;
  };
}
