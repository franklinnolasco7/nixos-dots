{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.backups.restic;

  # S3-compatible endpoint. Bucket name is not secret; the access credentials
  # come from the sops files in ~/.config/restic.
  b2Repository = "s3:https://s3.${cfg.b2Region}.backblazeb2.com/${cfg.b2Bucket}";

  pathArgs = lib.concatMapStringsSep " " (p: ''"${p}"'') cfg.paths;
  retentionArgs = lib.concatMapStringsSep " " (r: ''"${r}"'') cfg.retention;

  scripts = import ./scripts.nix {
    inherit
      pkgs
      b2Repository
      pathArgs
      retentionArgs
      ;
    inherit (cfg) sizeLimit;
  };

  inherit (scripts) restic-backup;
in
{
  options.backups.restic = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable the daily restic backup of user data to Backblaze B2. Needs the
        sops secrets declared in modules/nixos/tools/sops.nix and real repo
        credentials (see docs/backups.md).
      '';
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.home.homeDirectory}/Backups" ];
      description = "Absolute paths included in each backup run.";
    };

    sizeLimit = lib.mkOption {
      type = lib.types.int;
      default = 9 * 1024 * 1024 * 1024;
      description = ''
        Maximum total source size in bytes (9 GiB by default). B2 bills once
        the bucket passes 10 GB stored; restic dedups unchanged files, so
        stored size tracks source size. A source-size check runs before each
        upload and aborts with a notification if the source exceeds this
        budget.
      '';
    };

    retention = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--keep-daily=7"
        "--keep-weekly=4"
        "--keep-monthly=3"
      ];
      description = "Snapshot retention passed to restic forget --prune.";
    };

    b2Region = lib.mkOption {
      type = lib.types.str;
      default = "us-east-005";
      description = "Backblaze B2 region (e.g. us-west-002) for the S3 endpoint URL.";
    };

    b2Bucket = lib.mkOption {
      type = lib.types.str;
      default = "frank-restic-backups";
      description = "Name of the B2 bucket holding the restic repository.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.paths != [ ];
        message = "backups.restic.paths must not be empty when backups.restic.enable is true";
      }
    ];

    home.packages = [
      pkgs.restic
      restic-backup
    ];

    systemd.user.services.restic-backup = {
      Unit = {
        Description = "Daily restic backup to Backblaze B2";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${restic-backup}/bin/restic-backup";
      };
    };

    systemd.user.timers.restic-backup = {
      Unit.Description = "Daily restic backup to Backblaze B2";
      Timer = {
        OnCalendar = "*-*-* 02:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
