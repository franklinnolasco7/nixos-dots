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
        xdg-utils
        wl-clipboard
        wl-clip-persist
        (cliphist.overrideAttrs (old: {
          postInstall = old.postInstall + ''
            rm -f $out/bin/cliphist-rofi-img
          '';
        }))
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
      ]
    );
}
