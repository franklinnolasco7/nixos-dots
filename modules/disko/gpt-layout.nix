# Shared GPT partition layout for all hosts.
#
# Imported as a function by hosts/<host>/disko.nix, which passes the target
# `device` (the `device = lib.mkDefault "..."` line in the host file is also
# parsed by install/install.sh to print the destructive warning).
#
# NOTE: The host's disko.nix is imported twice; as a plain Nix function by
# disko's CLI (which reads `.disko.devices` straight from the file, so the
# NixOS module system `imports` must not be used here) and as a NixOS module
# via flake.nix mkSystem, where disko.nixosModules.disko derives
# fileSystems/swapDevices from the same layout at build time.
#
# Partition layout:
#
#   tmpfs (RAM)      -> / (stateless root; wiped every reboot)
#   GPT
#   ├── 1 GiB  EFI System Partition  -> /boot
#   └── rest    LUKS (luks-persist) -> ext4 -> /nix
#
# Root is a tmpfs: everything not explicitly persisted (impermanence,
# modules/nixos/system/impermanence.nix) is reset on reboot. The nix store
# and persistent state live on the LUKS-encrypted partition mounted at /nix;
# disko's initrdUnlock (default) generates the
# boot.initrd.luks.devices.luks-persist entry at build time, so no explicit
# boot module is needed. The passphrase is typed during install (disko) and
# again at boot. Swap comes from zramSwap (modules/nixos/system/boot.nix),
# not a disk partition.

{ device }:

{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=4G"
          "mode=755"
        ];
      };
    };

    disk.main = {
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
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          persist = {
            size = "100%";

            content = {
              type = "luks";
              name = "luks-persist";

              # dm-crypt passes discards through so the weekly fstrim.timer
              # reaches the NVMe; leaks which sectors are free to an attacker.
              settings.allowDiscards = true;

              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
