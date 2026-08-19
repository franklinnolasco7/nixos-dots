{ config, pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme.override {
        themeVariants = [ "default" ];
        colorVariants = [ "dark" ];
        sizeVariants = [ "standard" ];
        tweaks = [
          "black"
          "rimless"
        ];
      };
    };
    iconTheme = {
      name = "Tela-circle-black-dark";
      package = pkgs.tela-circle-icon-theme.override {
        colorVariants = [ "black" ];
      };
    };
    gtk4.extraCss = ''
      @import url("${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css");
    '';
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  xdg.configFile."gtk-4.0/assets".source =
    "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = config.gtk.theme.name;
      icon-theme = config.gtk.iconTheme.name;
    };
  };
}
