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
# ⚠ TEMPORARY: this file is NOT imported as a NixOS module right now —
# flake.nix gates disko-derived mounts to the vm host (useDiskoMounts) and
# hosts/aspire7/hardware-configuration.nix carries the live-disk UUIDs again
# so the laptop is safe to `switch` while iterating.
#
# Still imported by diskoConfigurations.aspire7 (manual disko runs) and by
# install/install.sh at the real install. REVERT the gate in flake.nix when
# installing for real (see TODO.md).
#
# Imported in two places when the gate is lifted:
#
#   - nixosConfigurations.aspire7 (via flake.nix mkSystem) — disko's NixOS
#     module turns the layout into fileSystems/swapDevices at build time, so
#     hardware-configuration.nix can stay UUID-free.
#   - diskoConfigurations.aspire7 — manual disko runs.
#
# Before running a destructive Disko command, ALWAYS verify that the
# by-id path still resolves to the intended physical disk.

{ lib, ... }:

import ../../modules/disko/gpt-layout.nix {
  device = lib.mkDefault "/dev/disk/by-id/nvme-HFM512GD3JX016N_FYB3N036910803I0I";
}
