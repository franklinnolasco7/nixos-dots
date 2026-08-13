{
  lib,
  ...
}:

{
  # System profile: "full" (desktop) or "minimal" (console TTY). Injected by
  # flake.nix mkSystem from the `profile` argument; every full/minimal gate
  # reads this typed option so a typo fails eval on the enum, not silently.
  options.myProfile = lib.mkOption {
    type = lib.types.enum [
      "full"
      "minimal"
    ];
    default = "full";
  };
}
