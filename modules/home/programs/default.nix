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
    ./firefox
    ./opencode
    ./gaming
    ./spotify
    ./obsidian
    ./thunar
    ./restic
  ];
}
