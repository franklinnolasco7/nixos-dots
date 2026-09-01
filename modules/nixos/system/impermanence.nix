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
      # Wholesale app state: subsumes bluetooth, libvirt, NetworkManager,
      # nixos, systemd/backlight (brightness), systemd/random-seed,
      # systemd/timers, systemd/coredump, upower, power-profiles-daemon,
      # cups, samba, alsa, ... Per the FHS this state must survive reboot.
      "/var/lib"
      "/var/log"
      # FHS: files in /var/tmp must not be deleted at boot.
      "/var/tmp"
      # App caches off the small tmpfs root; clean out stale entries manually.
      "/var/cache"
    ];

    files = [
      "/etc/machine-id"
      # SSH host identity: stable across reboots and reinstalls. install.sh
      # stages both halves into /nix/persist/etc/ssh.
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      # git safe.directory for root (install.sh stages it into persist).
      "/root/.gitconfig"
      # Ly display-manager state: last-selected user + session index.
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
}
