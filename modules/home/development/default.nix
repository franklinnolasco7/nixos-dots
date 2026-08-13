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
    # Language runtimes & build toolchains — full profile only.
    ./tooling.nix
  ];
}
