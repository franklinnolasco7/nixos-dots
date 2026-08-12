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
# Used only by diskoConfigurations.vm.

{ lib, ... }:

import ../../modules/disko/gpt-layout.nix {
  device = lib.mkDefault "/dev/vda";
}
