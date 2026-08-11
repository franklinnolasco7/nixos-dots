{ config, pkgs, ... }:
{
  # Bootloader: only show/keep the last 10 generations in the boot menu
  boot.loader.systemd-boot.configurationLimit = 10;

  # Automatic garbage collection — runs weekly, keeps store lean
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Optimize store automatically (dedupes identical files via hardlinks)
  nix.settings.auto-optimise-store = true;
}
