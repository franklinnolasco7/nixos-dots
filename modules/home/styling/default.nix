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
    # GUI theming — pointless without a display server.
    ./cursor.nix
    ./gtk.nix
    ./qt.nix
  ];
}
