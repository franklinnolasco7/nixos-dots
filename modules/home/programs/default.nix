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
    ./zed
    ./gaming.nix
    ./spotify
    ./obsidian
  ];
}
