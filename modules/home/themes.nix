{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    inter
    noto-fonts-color-emoji
  ];
}
