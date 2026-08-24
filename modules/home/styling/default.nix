{
  lib,
  profile,
  ...
}:
{
  imports = [
    ./fonts.nix
  ]
  ++ lib.optionals (profile == "full") [
    ./gtk.nix
    ./qt.nix
    ./cursor.nix
    ./palette.nix
  ];
}
