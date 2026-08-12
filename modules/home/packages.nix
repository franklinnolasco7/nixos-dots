{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Desktop & Utilities
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
    tree
    jq
    gawk
    curl
    lua
    wireguard-tools
    gh

    # Audio
    pavucontrol
    pulseaudio
  ];
}
