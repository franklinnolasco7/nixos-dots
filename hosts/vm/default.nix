# Host entry point for the QEMU/KVM rehearsal VM.
#
# hardware-configuration.nix is regenerated automatically during
# installation with nixos-generate-config (install.sh step 2); the committed
# placeholder only keeps `nix flake check` green before that happens.

{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
