# Host entry point for the QEMU/KVM rehearsal VM.
#
# hardware-configuration.nix is regenerated during installation by
# nixos-anywhere (nixos-generate-config --no-filesystems); fileSystems/swap
# come from ./disko.nix via flake.nix mkSystem. The committed placeholder only
# keeps `nix flake check` green before that happens.

{
  imports = [
    ./hardware-configuration.nix
    ./configuration.nix
  ];
}
