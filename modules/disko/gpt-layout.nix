# Shared GPT partition layout for all hosts.
#
# Imported as a function by hosts/<host>/disko.nix, which passes the target
# `device` (the `device = lib.mkDefault "..."` line in the host file is also
# parsed by install/install.sh to print the destructive warning).
#
# NOTE: This is a plain Nix function, not a NixOS module — disko's CLI reads
# `.disko.devices` straight from the imported file, so the NixOS module system
# (`imports`) must not be used here.
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
