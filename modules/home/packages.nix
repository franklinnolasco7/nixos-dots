{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.packages =
    # Core utilities — console-safe, always present (the minimal profile's tools).
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
    # Desktop & extra utilities — full profile only.
    ++ lib.optionals (config.myProfile == "full") (
      with pkgs;
      [
        obsidian
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

        # Hyprland Tools & Control
        hyprpicker
        hyprshot
        brightnessctl
        playerctl
        linuxPackages.cpupower

        # Editors
        neovim
        vscodium
        antigravity-ide

        # Terminal & Script Tools
        lua

        # Audio
        pavucontrol
        pulseaudio

        # LAN file sharing
        localsend
      ]
    );
}
