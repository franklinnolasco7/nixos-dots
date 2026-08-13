{
  lib,
  ...
}:

{
  # Home-side mirror of modules/nixos/options.nix. Injected by flake.nix
  # mkSystem via config.home-manager.users.<user>.myProfile.
  options.myProfile = lib.mkOption {
    type = lib.types.enum [
      "full"
      "minimal"
    ];
    default = "full";
  };
}
