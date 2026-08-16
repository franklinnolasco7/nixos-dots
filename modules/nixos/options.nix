{
  lib,
  ...
}:

{
  options.myProfile = lib.mkOption {
    description = ''
      System profile: "full" (desktop) or "minimal" (console TTY). Injected by
      flake.nix mkSystem from the `profile` argument; typed so a typo fails
      eval on the enum instead of silently building the default profile.
    '';
    type = lib.types.enum [
      "full"
      "minimal"
    ];
    default = "full";
  };

  # Host hardware defaults consumed by shared modules. hosts/<name>/ sets the
  # real values so forks and the VM degrade cleanly instead of inheriting a
  # wrong device path.
  options.myHost = {
    batteryPath = lib.mkOption {
      description = ''
        Path to the sysfs battery directory, e.g. /sys/class/power_supply/BAT1.
        Empty disables the battery-aware udev rules.
      '';
      type = lib.types.str;
      default = "";
    };
  };
}
