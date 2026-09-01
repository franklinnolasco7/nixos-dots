# Stateless root: everything on the tmpfs / is wiped every reboot; only state
# declared below survives, bind-mounted from the LUKS partition at /nix/persist
# (the `environment.persistence` root). /home is NOT managed here — it is a
# standard persistent mount of /nix/home (see hosts/*/configuration.nix).
#
# The nix store itself is already persistent on the /nix partition, so nothing
# here touches /nix/store.

{ pkgs, ... }:

{
  environment.persistence."/nix/persist" = {
    hideMounts = true;

    directories = [
      # WiFi passwords + saved connections (NM keyfile plugin path).
      "/etc/NetworkManager/system-connections"

      # /var/lib — explicit allowlist instead of blanket persist.
      # Each entry is the minimal set of state directories that must survive
      # reboot for the services this config actually enables.  The blanket
      # "/var/lib" was removed to avoid silently persisting security-sensitive
      # data (coredumps, stale journal) and to keep the tmpfs root small.
      #
      # When adding a new NixOS service, check whether it writes state here
      # and add the relevant subdirectory.
      "/var/lib/NetworkManager" # connection state, DHCP leases
      "/var/lib/systemd" # linger, random-seed, timers, backlight
      "/var/lib/nixos" # uid-map, group-map (NixOS identity)
      "/var/lib/bluetooth" # paired device records
      "/var/lib/alsa" # mixer state (volume levels)
      "/var/lib/upower" # battery history statistics
      "/var/lib/power-profiles-daemon" # active power profile
      "/var/lib/libvirt" # VM disks, networks, secrets
      "/var/lib/cups" # printer configs, SSL certs
      "/var/lib/samba" # machine account, share definitions
      "/var/lib/misc" # dnsmasq leases (NM DNS backend)
      # NOT persisted:
      #   /var/lib/systemd/coredump — security-sensitive process memory dumps
      #   /var/lib/pipewire — runtime-only, recreated each boot

      "/var/log"
      "/var/tmp"
      "/var/cache"
    ];

    files = [
      "/etc/machine-id"
      # SSH host identity: stable across reboots and reinstalls. install.sh
      # stages both halves into /nix/persist/etc/ssh.
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      # git safe.directory for root.  Dual provisioned: install.sh stages
      # this during initial install, and impermanence rebinds it on boot.
      # Both paths are needed — install.sh for first boot, impermanence
      # for every subsequent boot.
      "/root/.gitconfig"
      # Ly display-manager state: last-selected user + session index.
      # Remove this line if switching to a different display manager.
      "/etc/ly/save.txt"
    ];
  };

  # /etc/passwd, /etc/group and /etc/shadow are NOT bind-mounted: NixOS
  # regenerates them on the tmpfs root during activation, so a bind mount would
  # find a file already at the target and fail. Instead we copy /etc/shadow
  # (the one that changes via `passwd`) from persist at boot and back on
  # shutdown. passwd/group are declarative and regenerated identically each boot.
  systemd.services."persist-shadow-restore" = {
    description = "Restore /etc/shadow from persistent store";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    requires = [ "local-fs.target" ];
    before = [
      "systemd-logind.service"
      "systemd-user-sessions.service"
    ];
    script = ''
      if [[ -f /nix/persist/etc/shadow ]]; then
        ${pkgs.coreutils}/bin/install -m 0640 -o root -g shadow \
          /nix/persist/etc/shadow /etc/shadow
      fi
    '';
  };

  systemd.services."persist-shadow-save" = {
    description = "Persist /etc/shadow on shutdown";
    wantedBy = [ "shutdown.target" ];
    before = [ "shutdown.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.coreutils}/bin/install -m 0640 -o root -g shadow \
        /etc/shadow /nix/persist/etc/shadow
    '';
  };

  # Periodic cleanup for cache and logs that accumulate on the persistent
  # tmpfs-backed root.  Without these, /var/cache and /var/log grow unbounded
  # across reboots since impermanence bind-mounts them from the LUKS partition.
  systemd.tmpfiles.rules = [
    # Remove cache entries older than 7 days.
    "d /var/cache 0755 root root 7d"
    # Remove log files older than 14 days.
    "d /var/log 0755 root root 14d"
    # Remove any stray coredumps that may have been written before the
    # /var/lib/systemd/coredump exclusion took effect.
    "R /var/lib/systemd/coredump - - - - -"
  ];

  # NOTE: When adding new NixOS services, check if they write state to /etc or
  # /var/lib. If so, add the relevant paths to the persist declarations above.
  # A missing entry means the service's state silently resets on reboot — often
  # noticed only as "my WiFi vanished" or "the VM is gone."
}
