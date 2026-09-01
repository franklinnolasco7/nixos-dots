# WireGuard VPN via wg-quick + sops-nix.
#
# The wg0.conf file is managed as a sops secret (see modules/nixos/tools/sops.nix)
# and re-decrypted at every activation, so the config stays current after a
# reinstall without manual file copies. autostart = false means the tunnel is
# brought up by the vpn-toggle script (modules/home/scripts/vpn-toggle.nix),
# not at boot.

{ pkgs, config, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];

    networking.wg-quick.interfaces.wg0 = {
      configFile = config.sops.secrets."wg0-conf".path;
      autostart = false;
    };

    # Passwordless sudo for the vpn-toggle script
    # (modules/home/scripts/vpn-toggle.nix). It runs from the swaync control
    # center, which has no TTY, so sudo cannot prompt for a password. The rm is
    # arg-scoped to the exact resolvconf lock path; wg-quick/resolvconf are
    # binary-scoped (any invocation matches).
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/wg-quick";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/resolvconf";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/rm -f /run/resolvconf/lock";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
