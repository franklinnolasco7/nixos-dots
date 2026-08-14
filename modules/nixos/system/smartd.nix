{ ... }:
{
  # NVMe health monitoring: wear, pending sectors, temp. Defaults autodetect
  # all SMART-capable drives and monitor every attribute; pairs with the R2
  # backup story (#10) so the disk is watched before it dies.
  #
  # wall notifications are chosen over mail: no MTA is configured and this is
  # a single-user machine.
  services.smartd = {
    enable = true;
    notifications.wall.enable = true;
  };
}
