{
  lib,
  profile,
  ...
}:

{
  # nvidia + sops are host-specific and stay out of the shared default set
  # they are imported explicitly by hosts/aspire7/configuration.nix (the VM
  # skips them; see docs/architecture.md "Hosts").
  imports = lib.optionals (profile == "full") [
    # GUI/desktop feature modules; not part of the console-TTY minimal profile.
    ./desktop.nix
    ./gaming.nix
    ./virtualization.nix
  ];
}
