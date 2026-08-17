# ⚠ DESTRUCTIVE
#
# Disko will erase the target disk when run with:
#
#   --mode destroy,format,mount
#
# Target: physical Aspire 7 OS disk.
# Model:  SK hynix HFM512GD3JX016N
# Size:   ~512 GB
#
# VERIFIED stable device path:
#
# /dev/disk/by-id/nvme-HFM512GD3JX016N_FYB3N036910803I0I
#
# Do NOT replace this with /dev/nvme0n1.
#
# The partition layout lives in modules/disko/gpt-layout.nix (shared with
# other hosts); this file only pins the target device.
#
# Imported in two places:
#
#   - nixosConfigurations.aspire7 (via flake.nix mkSystem); disko's NixOS
#     module turns the layout into fileSystems/swapDevices at build time, so
#     hardware-configuration.nix can stay UUID-free.
#   - diskoConfigurations.aspire7; manual disko runs.
#
# Before running a destructive Disko command, ALWAYS verify that the
# by-id path still resolves to the intended physical disk.

{ lib, ... }:

import ../../modules/disko/gpt-layout.nix {
  device = lib.mkDefault "/dev/disk/by-id/nvme-HFM512GD3JX016N_FYB3N036910803I0I";
}
