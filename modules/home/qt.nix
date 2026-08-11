{ pkgs, lib, ... }:

let
  graphite-kde-theme = pkgs.fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Graphite-kde-theme";
    rev = "2022-02-08";
    # TODO: first build will fail with hash mismatch — copy the "got:" hash here.
    hash = lib.fakeHash;
  };
in
{
  home.packages = with pkgs; [
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum

    qt6ct
    qt5ct
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
