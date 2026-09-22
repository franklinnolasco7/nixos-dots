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

  time.timeZone = "Asia/Manila";

  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  system.stateVersion = "26.05";
}
