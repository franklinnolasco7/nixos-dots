{ user, ... }:

{
  # CUPS + mDNS printer discovery. No vendor drivers pinned: modern printers
  # (incl. HP AirPrint) work driverless; add one only when a model needs it.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.openFirewall = true;
  users.users.${user}.extraGroups = [ "lpadmin" ];
}
