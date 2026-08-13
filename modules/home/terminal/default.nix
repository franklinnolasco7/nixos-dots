{
  lib,
  profile,
  ...
}:

{
  # Console-safe shell + TUIs (always — the minimal profile's whole UI).
  imports = [
    ./shell.nix
  ]
  ++ lib.optionals (profile == "full") [
    # GUI terminal emulator — useless without a display server.
    ./emulator.nix
  ];
}
