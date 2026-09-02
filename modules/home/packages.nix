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
      gh
    ])
    ++ lib.optionals (config.myProfile == "full") (
      with pkgs;
      [
        curl
        jq
        gawk
        tree
        rtk
        wireguard-tools
        rsync

        ripgrep
        fd
        eza
        bat
        fzf

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
        ffmpeg
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
