{ ... }:
{
  # Explicit default-deny firewall; only SSH and LocalSend are exposed.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    53317
  ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
}
