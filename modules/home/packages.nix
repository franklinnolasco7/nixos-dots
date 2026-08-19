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
        libnotify
        chromium
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
        mpv

        hyprpicker
        hyprshot
        brightnessctl
        playerctl
        linuxPackages.cpupower

        neovim
        vscodium

        lua

        pavucontrol
        pulseaudio

        localsend
        ani-cli
        github-copilot-cli
        antigravity-ide-fhs
        codeburn
      ]
    );
}
