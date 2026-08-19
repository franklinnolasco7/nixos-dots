{ ... }:

let
  localSendPort = 53317;
in
{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    localSendPort
  ];
  networking.firewall.allowedUDPPorts = [ localSendPort ];
}
