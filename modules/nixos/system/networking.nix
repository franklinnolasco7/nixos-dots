{
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  # Lower Wi-Fi latency; powersave causes periodic RX stalls that jitter ping.
  networking.networkmanager.wifi.powersave = false;
  services.resolved.enable = true;
}
