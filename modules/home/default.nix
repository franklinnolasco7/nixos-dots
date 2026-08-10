{
  imports = [
    # Desktop
    ./hyprland.nix
    ./hyprctl.nix
    ./waybar.nix
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
    ./xdg.nix
    ./scripts.nix
  ];
}
