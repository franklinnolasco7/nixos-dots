{
  # nvidia + sops are host-specific and stay out of the shared default set —
  # they are imported explicitly by hosts/aspire7/configuration.nix (the VM
  # skips them; see docs/architecture.md "Hosts").
  imports = [
    ./gaming.nix
    ./virtualization.nix
  ];
}
