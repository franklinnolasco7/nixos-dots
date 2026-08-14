{ ... }:
{
  # Explicit default-deny firewall; only SSH is exposed.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
}
