{
  user,
  ...
}:

{
  # Samba for Thunar's "Share" context menu (thunar-shares-plugin in
  # desktop.nix). usershares.enable wires up the `samba` group, the
  # /var/lib/samba/usershares dir, and the smb.conf usershare defaults.
  services.samba = {
    enable = true;
    usershares.enable = true;
    openFirewall = true;
  };

  users.users.${user}.extraGroups = [ "samba" ];
}
