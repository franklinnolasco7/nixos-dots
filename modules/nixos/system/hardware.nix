{
  config,
  pkgs,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-utils
    ];
  };

  services.power-profiles-daemon.enable = true;

  # Quickshell's battery widget reads UPower; only battery hosts need the daemon.
  services.upower.enable = config.myHost.batteryPath != "";
}
