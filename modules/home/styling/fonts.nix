{
  config,
  lib,
  pkgs,
  ...
}:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      # The nerd font is a full-profile-only package (nerd glyphs are only
      # rendered by kitty/starship/fastfetch in the desktop profile); the base
      # JetBrains Mono stays in the fallback chain so it is always present.
      monospace = [
        "JetBrains Mono"
      ]
      ++ lib.optionals (config.myProfile == "full") [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Inter" ];
      serif = [ "Noto Serif" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  home.packages =
    with pkgs;
    [
      inter
      noto-fonts
      noto-fonts-color-emoji
    ]
    ++ lib.optionals (config.myProfile == "full") [
      # Nerd-glyph font; the full profile's terminal/starship/fastfetch glyphs.
      nerd-fonts.jetbrains-mono
    ];
}
