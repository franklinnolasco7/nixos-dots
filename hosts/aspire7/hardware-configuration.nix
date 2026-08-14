# ⚠ TEMPORARY: disko-module mounts are gated to the vm host (flake.nix
# useDiskoMounts), so this file carries the physical Aspire 7's partition
# UUIDs again — matching the live disk, making `nixos-rebuild switch
# --flake .#aspire7` safe while iterating.
#
# REVERT before the real install: nixos-anywhere regenerates this file with
# nixos-generate-config (--no-filesystems) and fileSystems/swapDevices come
# from hosts/aspire7/disko.nix again (re-enable useDiskoMounts). (TODO.md)

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4250d055-5cb2-4b26-b3cb-f63e890eb525";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/02E4-F604";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-uuid/5a84cee4-ecba-4319-9411-147c07d90691";
    }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
