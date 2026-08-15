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

  # Host hardware defaults consumed by shared modules. Empty string means the
  # feature is skipped; hosts/<name>/ sets the real values so forks and the VM
  # degrade cleanly instead of inheriting a wrong device path.
  options.myHost = {
    # sysfs battery path used by battery-aware udev rules.
    batteryPath = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
}
