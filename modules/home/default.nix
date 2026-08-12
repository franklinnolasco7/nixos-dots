{
  imports = [
    # Desktop
    ./wayland
    ./hyprctl
    ./waybar
    ./rofi
    ./swaync
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
    ./opencode

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
    ./scripts
  ];
}
