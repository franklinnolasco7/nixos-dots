{
  config,
  inputs,
  pkgs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  colors = config.lib.stylix.colors;
in
{
  programs.spicetify = {
    enable = true;
    spotifyPackage = pkgs.spotify;
    spicetifyPackage = pkgs.spicetify-cli;

    theme = spicePkgs.themes.text;
    colorScheme = "custom";
    customColorScheme = {
      text = colors.base0F;
      subtext = colors.base0A;
      sidebar-text = colors.base0F;
      main = colors.base00;
      sidebar = colors.base01;
      player = colors.base01;
      card = colors.base02;
      shadow = colors.base00;
      selected-row = colors.base02;
      button = colors.base0F;
      button-active = colors.base0D;
      button-disabled = colors.base04;
      tab-active = colors.base0D;
      notification = colors.base02;
      notification-error = colors.base04;
      misc = colors.base0F;
    };

    enabledExtensions = with spicePkgs.extensions; [
      shuffle
      hidePodcasts
    ];

    enabledCustomApps = [
      spicePkgs.apps.marketplace
    ];
  };
}
