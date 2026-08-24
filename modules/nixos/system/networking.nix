{
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    # Lower Wi-Fi latency; powersave causes periodic RX stalls that jitter ping.
    wifi.powersave = false;
  };
  services.resolved.enable = true;
}
