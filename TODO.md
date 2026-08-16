# TODO

Tracked temporary states that must not be lost. The flake comments referencing
this file are the only other record, keep them in sync.

## Revert the aspire7 disko-mounts gate (before the real install)

`useDiskoMounts = false` was gated off so `nixos-rebuild switch --flake .#aspire7`
is safe on the live laptop while iterating (the live disk has no
`disk-main-*` partlabels, so disko-derived mounts would produce an unbootable
config).

Revert checklist (in order):

1. Re-enable `useDiskoMounts = true` for `aspire7` and `aspire7-min` in
   `flake.nix` (drop the `# ⚠ TEMPORARY` comments there and in the `aspire7`
   config).
2. Let `nixos-anywhere` regenerate the UUID-free
   `hosts/aspire7/hardware-configuration.nix` (`--no-filesystems`) and commit
   it.
3. Remove this section.