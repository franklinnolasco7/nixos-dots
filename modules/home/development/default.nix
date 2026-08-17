{
  lib,
  profile,
  ...
}:

{
  imports = [
    ./git.nix
  ]
  ++ lib.optionals (profile == "full") [
    ./tooling.nix
  ];
}
