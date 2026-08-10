{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # Desktop
    kitty
    rofi
    thunar
    libnotify
    swaynotificationcenter
    chromium

    # Editors
    neovim
    vscodium
    micro

    # Terminal tools
    tree
    btop
    fastfetch
    htop

    # TEMP WORKAROUND: waybar-git build (Hyprland Lua dispatch fix).
    # Switch back to pkgs.waybar when nixpkgs ships the fix.
    inputs.waybar.packages.${pkgs.system}.default
  ];
}
