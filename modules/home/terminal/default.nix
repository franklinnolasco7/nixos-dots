{
  lib,
  profile,
  ...
}:

{
  imports = [
    ./shell.nix
  ]
  ++ lib.optionals (profile == "full") [
    ./emulator.nix
    ./tui.nix
  ];
}
