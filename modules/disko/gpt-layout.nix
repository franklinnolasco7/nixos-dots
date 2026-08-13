# Shared GPT partition layout for all hosts.
#
# Imported as a function by hosts/<host>/disko.nix, which passes the target
# `device` (the `device = lib.mkDefault "..."` line in the host file is also
# parsed by install/install.sh to print the destructive warning).
#
# NOTE: The host's disko.nix is imported twice — as a plain Nix function by
# disko's CLI (which reads `.disko.devices` straight from the file, so the
# NixOS module system `imports` must not be used here) and as a NixOS module
# via flake.nix mkSystem, where disko.nixosModules.disko derives
# fileSystems/swapDevices from the same layout at build time.
#
# Partition layout:
#
#   GPT
#   ├── 1 GiB  EFI System Partition  -> /boot
#   ├── 8 GiB  swap
#   └── rest    ext4                  -> /

{ device }:

{
  disko.devices.disk.main = {
    type = "disk";
    inherit device;

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
