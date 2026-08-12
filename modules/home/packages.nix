{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Desktop & Utilities
    kitty
    obsidian
    rofi
    rofimoji
    thunar
    libnotify
    swaynotificationcenter
    chromium
    firefox
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
    micro

    # AI Tools
    opencode

    # Terminal & Script Tools
    tree
    fastfetch
    htop
    jq
    gawk
    curl
    lua
    wireguard-tools
    cava
    gh

    # Audio
    pavucontrol
    pulseaudio

    waybar
  ];
}
