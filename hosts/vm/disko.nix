# ⚠ DESTRUCTIVE
#
# Disko will erase the target disk when run with:
#
#   --mode destroy,format,mount
#
# Target: QEMU/KVM rehearsal disk (virtio).
#
# VERIFIED stable device path:
#
# /dev/vda
#
# Shares the GPT layout from modules/disko/gpt-layout.nix with the physical
# Aspire 7 so the installer flow is rehearsed 1:1, minus the NVMe by-id path.
#
# Imported in two places:
#
#   - nixosConfigurations.vm (via flake.nix mkSystem) — disko's NixOS module
#     turns the layout into fileSystems/swapDevices at build time, so
#     hardware-configuration.nix can stay UUID-free.
#   - diskoConfigurations.vm — manual disko runs.

{ lib, ... }:

import ../../modules/disko/gpt-layout.nix {
  device = lib.mkDefault "/dev/vda";
}
