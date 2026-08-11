{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirt.qemu.enable = true;

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
  ];
}
