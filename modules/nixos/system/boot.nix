{
  # Bootloader: only show/keep the last 10 generations in the boot menu
  boot.loader.systemd-boot.configurationLimit = 10;
  # Default "keep" retains the firmware's low-res GOP mode, which renders the
  # menu zoomed; "max" picks the highest advertised mode (native on a real
  # panel, the virtio EDID in the VM) without hardcoding a resolution.
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
