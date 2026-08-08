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
# Partition layout:
#
#   GPT
#   ├── 1 GiB  EFI System Partition  -> /boot
#   ├── 8 GiB  swap
#   └── rest    ext4                  -> /
#
# The root partition is last and uses the remaining disk space.
#
# This file is intentionally NOT imported into the normal
# nixosConfigurations.aspire7 module list.
#
# It is used only by:
#
#   diskoConfigurations.aspire7
#
# Before running a destructive Disko command, ALWAYS verify that the
# by-id path still resolves to the intended physical disk.

{ lib, ... }:

{
  disko.devices.disk.main = {
    type = "disk";

    device =
      lib.mkDefault
        "/dev/disk/by-id/nvme-HFM512GD3JX016N_FYB3N036910803I0I";

    content = {
      type = "gpt";

      partitions = {
        boot = {
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";

            mountOptions = [
              "fmask=0022"
              "dmask=0022"
            ];
          };
        };

        swap = {
          size = "8G";

          content = {
            type = "swap";
          };
        };

        root = {
          size = "100%";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
