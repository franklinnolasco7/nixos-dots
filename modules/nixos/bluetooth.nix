{
  # Bluetooth stack + Blueman manager.
  #
  # No chipset/firmware/device-path assumptions: physical Bluetooth device
  # verification happens on the real Aspire 7.

  hardware.bluetooth.enable = true;
  services.blueman.enable = true; # waybar on-click: blueman-manager
}
