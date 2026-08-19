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
    ./opencode
    ./gaming.nix
    ./spotify
    ./obsidian
  ];
}
