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
    ./stylix.nix
  ];
}
