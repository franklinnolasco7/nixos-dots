# Backups

Encrypted, versioned, daily restic backups of user data to **Backblaze B2**
off-site (3-2-1: 3 copies, 1+ offsite). B2 is free at this data size (10 GB,
free egress up to 3x storage).

Declared in `modules/home/programs/restic/`:

- **Paths**: `backups.restic.paths` (default `~/Backups`). Changing what gets
  backed up means editing the module and rebuilding — there is no editable
  runtime file.
- **Free-tier budget**: `backups.restic.sizeLimit` (default `9 GiB`). B2 bills
  once the bucket passes 10 GB stored; restic dedups unchanged files, so stored
  size tracks source size. Before uploading, the script sums the source and
  aborts with a notification (nothing uploaded) if it exceeds this ceiling.
- **Retention**: `backups.restic.retention` (`--keep-daily=7
  --keep-weekly=4 --keep-monthly=3`).
- **Schedule**: systemd user timer `restic-backup.timer`, daily 02:00,
  `Persistent=true`, 30 min jitter. A failed run notifies via notify-send.

Enabled on the physical host via `backups.restic.enable = true`
(`hosts/aspire7/home.nix`). The VM and the minimal profile leave it off.

> [!NOTE]
> Originally planned as R2 + B2 (two independent providers); R2 is deferred
> until the account is set up. The module is B2-only for now — adding R2 later
> means re-adding the provider call, two options and two secrets.

## One-time setup

The only manual steps: create the bucket + credentials (below), set the repo
endpoint in the module, and fill the sops secrets. restic `init` for the repo
happens automatically on the first successful run.

## Free-tier budget

B2's free tier is **10 GB stored**; storage above that is billed. restic keeps
stored size ≈ source size (dedup across snapshots), so the module caps the
source with `backups.restic.sizeLimit` (default `9 GiB` to leave margin for
restic tree overhead). If the source exceeds it, the run aborts with a
notification before anything is uploaded.

To check current usage:

```bash
export RESTIC_REPOSITORY=s3:https://s3.<region>.backblazeb2.com/<bucket>
export AWS_ACCESS_KEY_ID=$(cat ~/.config/restic/b2-key-id)
export AWS_SECRET_ACCESS_KEY=$(cat ~/.config/restic/b2-application-key)
export RESTIC_PASSWORD_FILE=~/.config/restic/restic-password
restic stats --mode raw-data latest     # bytes in the latest snapshot
```

The `latest` snapshot is not the whole repository; pruned/deleted data from
older snapshots can still be stored.

Raise or lower the ceiling by editing the `sizeLimit` default.

### 1. Backblaze B2

1. Create a bucket (e.g. `nixos-backup-b2`). Make it **private**.
2. Create an **Application Key**: App Keys, allow access to only that bucket,
   capabilities **List Files, Read Files, Write Files, Delete Files**.
3. Note the **region endpoint** for your bucket (e.g. `s3.us-west-002.backblazeb2.com`).

Endpoint: `s3:https://s3.<region>.backblazeb2.com/<bucket>`

### 2. Set the repo endpoint in the module

In `modules/home/programs/restic/default.nix`, replace the placeholder
defaults of `backups.restic.b2Region` and `backups.restic.b2Bucket`.

### 3. Fill the sops secrets

```bash
nix shell nixpkgs#sops -c sops secrets/secrets.yaml
```

Set the three values (placeholder values make backups fail with a notification
until they are real — safe):

| Key                   | Value                            |
| --------------------- | -------------------------------- |
| `b2-key-id`           | B2 Application Key ID            |
| `b2-application-key`  | B2 Application Key secret        |
| `restic-password`     | Repository password (keep it somewhere safe) |

### 4. Rebuild

```bash
install/rebuild.sh aspire7 build
install/rebuild.sh aspire7
```

## Verify

```bash
systemctl --user list-timers restic-backup          # timer armed
systemctl --user start restic-backup                # run once now
journalctl --user -u restic-backup                  # output / failure notices
```

Or directly, with the same env the service uses:

```bash
export RESTIC_REPOSITORY=s3:https://s3.<region>.backblazeb2.com/<bucket>
export AWS_ACCESS_KEY_ID=$(cat ~/.config/restic/b2-key-id)
export AWS_SECRET_ACCESS_KEY=$(cat ~/.config/restic/b2-application-key)
export RESTIC_PASSWORD_FILE=~/.config/restic/restic-password
restic snapshots
```

## Restore

```bash
export RESTIC_REPOSITORY=s3:https://s3.<region>.backblazeb2.com/<bucket>
export AWS_ACCESS_KEY_ID=$(cat ~/.config/restic/b2-key-id)
export AWS_SECRET_ACCESS_KEY=$(cat ~/.config/restic/b2-application-key)
export RESTIC_PASSWORD_FILE=~/.config/restic/restic-password

restic snapshots                     # pick a snapshot id
restic restore <snapshot-id> --target ~/restore
# or only a path:
restic restore latest --include Documents --target ~/restore
```