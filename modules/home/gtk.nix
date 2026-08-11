{ pkgs, ... }:
{
  gtk = {
    enable = true;
    theme = {
      name = "Graphite-Dark";
      package = pkgs.graphite-gtk-theme.override {
        themeVariants = [ "default" ];
        colorVariants = [ "dark" ];
        sizeVariants  = [ "standard" ];
        tweaks        = [ "rimless" ];
      };
    };
    iconTheme = {
      name = "Tela-circle-black-dark";
      package = pkgs.tela-circle-icon-theme.override {
        colorVariants = [ "black" ];
      };
    };
  };
}
