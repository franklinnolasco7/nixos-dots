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
  };
}
