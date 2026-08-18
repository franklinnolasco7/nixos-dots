{ inputs, pkgs, ... }:

{
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify;
    spicetifyPackage = pkgs.spicetify-cli;
    enabledCustomApps = [
      inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.apps.marketplace
    ];
  };
}
