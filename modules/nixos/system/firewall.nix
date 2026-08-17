{ ... }:
{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    53317
  ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
}
