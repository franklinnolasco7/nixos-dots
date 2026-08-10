{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}