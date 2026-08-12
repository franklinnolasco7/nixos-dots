{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "JetBrainsMono Nerd Font"
        "JetBrains Mono"
      ];
      sansSerif = [ "Inter" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts
    noto-fonts-color-emoji
  ];
}
