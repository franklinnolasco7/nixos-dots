{ ... }:

let
  localSendPort = 53317;
in
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      localSendPort
    ];
    allowedUDPPorts = [ localSendPort ];
  };
}
