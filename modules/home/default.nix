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

    # Editors & apps
    ./programs

    # Development
    ./development

    # Packages & theming
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
