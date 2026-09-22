# Common settings shared by every host.
#
# Host-specific values (hostname, PRIME bus IDs, display manager, ...) stay in
# hosts/<host>/configuration.nix.

{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libx11
      libxcb
      libGL
      mesa
      libgbm
      libdrm
      fontconfig
      expat
      alsa-lib
      e2fsprogs
      libgpg-error
      sqlite
    ];
  };

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  system.stateVersion = "26.05";
}
