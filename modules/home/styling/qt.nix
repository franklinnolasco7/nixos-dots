{
  config,
  lib,
  pkgs,
  ...
}:

let
  colors = config.lib.stylix.colors.withHashtag;

  graphite-kde-theme = pkgs.fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Graphite-kde-theme";
    rev = "09665ba967475da01ad9ec2a5a5822f15ba14e84";
    hash = "sha256-4Uw6MgfiAzcbhuEPX7XEuj/8m7sL/kU0h2k7gu2OD+o=";
  };

  recolor =
    lib.replaceStrings
      [
        # Graphite-rimless dark source colors
        "#2c2c2c"
        "#2e2e2e"
        "#4d4d4d"
        "#535353"
        "#474747"
        "#282828"
        "#323232"
        "#1a1a1a"
        "#212121"
        "#1f1f1f"
        "#1e1e1e"
      ]
      [
        # Mapped to base16 palette tokens
        colors.base00
        colors.base00
        colors.base02
        colors.base03
        colors.base02
        colors.base00
        colors.base00
        colors.base00
        colors.base00
        colors.base00
        colors.base00
      ];

  graphite-black-kvconfig = recolor (
    builtins.readFile "${graphite-kde-theme}/Kvantum/Graphite-rimless/Graphite-rimlessDark.kvconfig"
  );

  graphite-black-svg = recolor (
    builtins.readFile "${graphite-kde-theme}/Kvantum/Graphite-rimless/Graphite-rimlessDark.svg"
  );
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
    "Kvantum/GraphiteBlack/GraphiteBlack.kvconfig".text = graphite-black-kvconfig;

    "Kvantum/GraphiteBlack/GraphiteBlack.svg".text = graphite-black-svg;

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=GraphiteBlack
    '';
  };
}
