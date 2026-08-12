{
  imports = [
    # Desktop
    ./hyprland.nix
    ./hyprctl.nix
    ./waybar
    ./rofi.nix
    ./swaync.nix
    ./wallpapers.nix

    # Terminal
    ./zsh
    ./starship
    ./kitty
    ./btop.nix
    ./cava
    ./fastfetch
    ./htop

    # Editors
    ./micro
    ./opencode.nix

    # Development
    ./git.nix
    ./development.nix

    # Packages & theming
    ./packages.nix
    ./themes.nix
    ./gtk.nix
    ./qt.nix
    ./cursor.nix
    ./xdg.nix
    ./scripts.nix
  ];
}
