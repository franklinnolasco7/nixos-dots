{
  lib,
  ...
}:

{
  # Home-side mirror of modules/nixos/options.nix. Injected by flake.nix
  # mkSystem via config.home-manager.users.<user>.myProfile; hosts/<name>/
  # sets the real myHost values so forks and the VM degrade cleanly.
  options.myProfile = lib.mkOption {
    description = ''
      Home-side mirror of myProfile in modules/nixos/options.nix: "full" or
      "minimal". Injected by flake.nix via config.home-manager.users.<user>.myProfile.
    '';
    type = lib.types.enum [
      "full"
      "minimal"
    ];
    default = "full";
  };

  options.myPalette = lib.mkOption {
    description = ''
      Base16 hex values (without "#") for home-module theming.
      Empty in the minimal profile so console stays unthemed.
    '';
    type = lib.types.attrsOf lib.types.str;
    default = { };
  };

  options.myHost = {
    batteryPath = lib.mkOption {
      description = ''
        Path to the sysfs battery directory used by battery-notify. Empty
        skips the script.
      '';
      type = lib.types.str;
      default = "";
    };
    backlightDevice = lib.mkOption {
      description = ''
        Backlight device name for the swaync backlight widget. Empty hides
        the widget.
      '';
      type = lib.types.str;
      default = "";
    };
  };
}
