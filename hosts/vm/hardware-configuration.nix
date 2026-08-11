# PLACEHOLDER for the rehearsal VM.
#
# Overwritten during installation by install.sh step 2:
#
#   nixos-generate-config --root /mnt
#
# The real (virtio/UUID-specific) hardware-configuration.nix is generated
# inside the VM and lives only in the VM's clone — it is not committed.

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

  fileSystems."/" = {
    device = "/dev/vda3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/vda1";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/vda2"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
