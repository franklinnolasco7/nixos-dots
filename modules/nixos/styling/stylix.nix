{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = lib.mkIf (config.myProfile == "full") {
    enable = true;
    image = ./../../../themes/wallpapers/wallpaper-070.png;
    polarity = "dark";
    base16Scheme = ./../../../themes/base16/dark.yaml;
    override = { };

    cursor = {
      package = pkgs.apple-cursor;
      name = "macOS";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.tela-circle-icon-theme.override {
        colorVariants = [ "black" ];
      };
      dark = "Tela-circle-black-dark";
      light = "Tela-circle-black-dark";
    };

    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    autoEnable = false;

    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };

    targets = {
      gtk.enable = false;
    };
  };
}
