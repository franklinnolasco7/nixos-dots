{ pkgs, ... }:

let
  graphite-kde-theme = pkgs.fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Graphite-kde-theme";
    rev = "2022-02-08";
    hash = "sha256-bltA0RDxE76iVqT5dVGsMXgaxkEDMV28vvM1t4Mu1l4=";
  };
in
{
  home.packages = with pkgs; [
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum

    qt6Packages.qt6ct
    libsForQt5.qt5ct
  ];

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "kvantum";
      package = pkgs.kdePackages.qtstyleplugin-kvantum;
    };
  };

  xdg.configFile = {
    "Kvantum/Graphite".source = "${graphite-kde-theme}/Kvantum/Graphite";

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=GraphiteDark
    '';
  };
}
