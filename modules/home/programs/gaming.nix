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
    # MANGOHUD=1 + MANGOHUD_DLSYM=1 for every app started from the session.
    # Steam games pick it up because mangohud is in the Steam FHS env
    # (modules/nixos/tools/gaming.nix).
    enableSessionWide = true;
  };
}
