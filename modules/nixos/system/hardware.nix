{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      libva-utils
    ];
  };

  services.power-profiles-daemon.enable = true;
}
