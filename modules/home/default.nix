{
  lib,
  profile,
  ...
}:

{
  imports = [
    ./options.nix

    # Terminal (always — console-safe)
    ./terminal

    ./programs
    ./development
    ./packages.nix
    ./styling
  ]
  ++ lib.optionals (profile == "full") [
    # Desktop-only (Wayland stack, MIME integration, GUI scripts)
    ./wayland
    ./xdg
    ./scripts
  ];
}
