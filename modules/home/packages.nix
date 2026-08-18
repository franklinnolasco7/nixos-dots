{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages =
    # Core utilities; console-safe, always present (the minimal profile's tools).
    (with pkgs; [
      curl
      jq
      gawk
      tree
      gh
      rtk
      wireguard-tools
      rsync
    ])
    ++ lib.optionals (config.myProfile == "full") (
      with pkgs;
      [
        rofimoji
        thunar
        libnotify
        chromium
        firefox
        vesktop
        xdg-utils
        wl-clipboard
        wl-clip-persist
        cliphist
        imv
        imagemagick
        awww
        waypaper
        grim
        slurp
        satty
        glib

        hyprpicker
        hyprshot
        brightnessctl
        playerctl
        linuxPackages.cpupower

        neovim
        vscodium
        antigravity-cli

        lua

        pavucontrol
        pulseaudio

        localsend
        ani-cli
      ]
    );
}
