{
  lib,
  profile,
  ...
}:

{
  imports = [
    ./micro
  ]
  ++ lib.optionals (profile == "full") [
    ./awww
    ./brightnessctl
    ./cliphist
    ./cpupower
    ./ffmpeg
    ./firefox
    ./gaming
    ./grim
    ./hyprpicker
    ./hyprshot
    ./imagemagick
    ./imv
    ./obsidian
    ./opencode
    ./playerctl
    ./restic
    ./rofimoji
    ./satty
    ./slurp
    ./spotify
    ./thunar
    ./vesktop
    ./wl-clipboard
  ];
}
