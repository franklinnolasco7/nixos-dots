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
    ./zsh.nix
    ./starship.nix
    ./kitty.nix
    ./btop.nix
    ./cava.nix
    ./fastfetch.nix
    ./htop.nix

    # Editors
    ./micro.nix
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
