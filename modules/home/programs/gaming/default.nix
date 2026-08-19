{ pkgs, ... }:

{
  home.packages = [
    (pkgs.heroic.override {
      # gamescope/gamemode must live inside Heroic's FHS wrapper for games to
      # use them (both already enabled system-wide in modules/nixos/tools/gaming.nix).
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
  };
}
