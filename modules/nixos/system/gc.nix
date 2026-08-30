{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    auto-optimise-store = true;
    # Auto-GC when the store fills past 10G, keeping 5G free.
    min-free = "5G";
    max-free = "10G";
    keep-derivations = false;
  };
}
