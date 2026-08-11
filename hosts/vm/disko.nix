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
# Same GPT layout as the physical Aspire 7 (hosts/aspire7/disko.nix) so the
# installer flow is rehearsed 1:1, minus the NVMe by-id path.
#
# Partition layout:
#
#   GPT
#   ├── 1 GiB  EFI System Partition  -> /boot
#   ├── 8 GiB  swap
#   └── rest    ext4                  -> /
#
# Used only by diskoConfigurations.vm.

{ lib, ... }:

{
  disko.devices.disk.main = {
    type = "disk";

    device = lib.mkDefault "/dev/vda";

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
