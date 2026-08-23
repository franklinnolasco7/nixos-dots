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
    ./vesktop
    ./obsidian
    ./thunar
    ./restic
  ];
}
