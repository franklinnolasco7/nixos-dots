{ config, ... }:

{
  imports = [
    ./cliphist-rofi-img.nix
    ./hypr-keybinds.nix
    ./rofi-web-search.nix
    ./style.nix
    ./wallpaper.nix
  ];

  home.file."${config.xdg.configHome}/rofi/config.rasi".force = true;
  xdg.configFile."rofi/theme-wallpaper.rasi".force = true;

  programs.rofi = {
    enable = true;
    font = "Inter 12";

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "󰀻";
      display-run = "";
      display-window = "";
      kb-mode-next = "Shift+Right,Control+Tab";
      kb-mode-previous = "Shift+Left,Control+ISO_Left_Tab";
      kb-mode-complete = "";
    };
  };
}
