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
    ./firefox.nix
    ./opencode
    ./gaming.nix
    ./spotify
    ./obsidian
  ];
}
