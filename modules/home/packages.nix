{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Desktop & Utilities
    kitty
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

    # Hyprland Tools & Control
    hyprpicker
    hyprshot
    hyprlock
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
    btop
    fastfetch
    htop
    jq
    gawk
    curl
    lua
    wireguard-tools

    # Audio
    pavucontrol
    pulseaudio

    # TEMP WORKAROUND: waybar-git build (Hyprland Lua dispatch fix).
    # Switch back to pkgs.waybar when nixpkgs ships the fix.
    inputs.waybar.packages.${pkgs.system}.default
  ];
}
