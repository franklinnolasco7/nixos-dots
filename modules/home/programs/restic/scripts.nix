{
  pkgs,
  b2Repository,
  pathArgs,
  retentionArgs,
  sizeLimit,
}:

let
  restic-backup = pkgs.writeShellScriptBin "restic-backup" ''
    set -uo pipefail

    export PATH="${pkgs.restic}/bin:${pkgs.libnotify}/bin:${pkgs.util-linux}/bin:/run/current-system/sw/bin:/usr/bin:/bin"

    SECRETS_DIR="$HOME/.config/restic"

    # restic output is logged to the journal so failures are visible in
    # journalctl --user -u restic-backup. A file is needed because restic's
    # S3 backend retries rejected requests (e.g. bad B2 credentials) with
    # backoff for a long time; discarding output would hide that as a hang.
    LOG_FILE="$(mktemp)"
    trap 'rm -f "$LOG_FILE"' EXIT

    notify() {
      local msg="$1"
      if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical -a restic-backup "restic-backup" "$msg" 2>/dev/null || logger -t restic-backup "$msg"
      else
        logger -t restic-backup "$msg"
      fi
    }

    log_and_notify() {
      local name="$1" msg="$2"
      cat "$LOG_FILE" 2>/dev/null | logger -t restic-backup
      notify "''${name}: ''${msg}"
    }

    paths=( ${pathArgs} )
    retention=( ${retentionArgs} )

    # Declared paths are the contract; missing ones fail loudly instead of
    # silently backing up less than the module promises.
    for p in "''${paths[@]}"; do
      if [[ ! -e "$p" ]]; then
        notify "backup path missing: ''${p}"
        exit 1
      fi
    done

    # Free-tier budget: B2 bills once the bucket passes 10 GB stored, and
    # stored size tracks source size (restic dedups unchanged files). Abort
    # before uploading if the source exceeds the configured ceiling.
    total=0
    for p in "''${paths[@]}"; do
      sz=$(du -sb "$p" 2>/dev/null | cut -f1) || {
        notify "backup source scan failed: ''${p}"
        exit 1
      }
      total=$(( total + sz ))
    done
    if (( total > ${toString sizeLimit} )); then
      notify "backup source ''${total} bytes exceeds ${toString sizeLimit} budget; nothing uploaded"
      exit 1
    fi

    run_provider() {
      local name="$1" repo="$2" key_file="$3" secret_file="$4"
      local access_key secret_key

      access_key=$(cat "$SECRETS_DIR/$key_file" 2>/dev/null) || {
        notify "''${name}: missing credential ''${key_file}"
        return 1
      }
      secret_key=$(cat "$SECRETS_DIR/$secret_file" 2>/dev/null) || {
        notify "''${name}: missing credential ''${secret_file}"
        return 1
      }

      export RESTIC_REPOSITORY="$repo"
      export AWS_ACCESS_KEY_ID="$access_key"
      export AWS_SECRET_ACCESS_KEY="$secret_key"
      export RESTIC_PASSWORD_FILE="$SECRETS_DIR/restic-password"

      # Auto-init: the first run after bucket creation sets up the repo.
      # Bounded by timeout so a rejected credential (restic retries auth
      # errors with backoff for a long time) can't stall the service forever.
      if ! timeout 120 restic snapshots >/dev/null 2>&1; then
        timeout 120 restic init >"$LOG_FILE" 2>&1 || {
          log_and_notify "''${name}" "restic init failed; check credentials and endpoint"
          return 1
        }
      fi

      restic backup "''${paths[@]}" >"$LOG_FILE" 2>&1 || {
        log_and_notify "''${name}" "backup failed"
        return 1
      }
      restic forget --prune "''${retention[@]}" >"$LOG_FILE" 2>&1 || {
        log_and_notify "''${name}" "forget --prune failed"
        return 1
      }
    }

    # One provider: failure notifies and exits non-zero.
    run_provider "B2" "${b2Repository}" b2-key-id b2-application-key
  '';
in
{
  inherit restic-backup;
}
