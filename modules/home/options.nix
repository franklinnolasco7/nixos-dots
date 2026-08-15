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

  # Home-side mirror of the myHost defaults in modules/nixos/options.nix.
  options.myHost = {
    # sysfs battery path used by battery-notify; "" skips the script.
    batteryPath = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    # backlight device for the swaync widget; "" hides the widget.
    backlightDevice = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
}
