#!/usr/bin/env bash
# Back up the secrets-decryption identities before wiping the disk.
#
# Run ON THE CURRENT SYSTEM before a fresh install:
#   sudo bash install/backup-host-key.sh            # auto-detect USB, pick one
#   sudo bash install/backup-host-key.sh /some/path # save to an explicit dir
#
# With no argument it lists removable drives (lsblk RM=1), lets you pick one,
# mounts it if needed, and saves the backup there. With a dest-dir argument it
# saves straight there (no prompt).
#
# Backs up:
#   1. /etc/ssh/ssh_host_ed25519_key{,.pub}  — sops age identity derived from
#      this host key; a fresh install regenerates it, making secrets unreadable.
#   2. ~/.config/sops/age/keys.txt            — user age key (user-frank), a
#      second decryption identity registered in .sops.yaml.
#
# The destination must survive the wipe (USB stick, separate disk, etc.).
set -euo pipefail

DEST_ARG="${1:-}"

if [[ $EUID -ne 0 ]]; then
  echo "error: run as root (sudo) — reads /etc/ssh and may mount the USB" >&2
  exit 1
fi

if [[ ! -f /etc/ssh/ssh_host_ed25519_key ]]; then
  echo "error: /etc/ssh/ssh_host_ed25519_key not found" >&2
  exit 1
fi

# Locate the real user (sudo resets $HOME to /root).
real_user="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
user_home="$(getent passwd "$real_user" | cut -d: -f6)"
user_age_key="$user_home/.config/sops/age/keys.txt"

backup_to() {
  local dest="$1"
  mkdir -p "$dest"

  install -m 0600 /etc/ssh/ssh_host_ed25519_key "$dest/ssh_host_ed25519_key"
  install -m 0644 /etc/ssh/ssh_host_ed25519_key.pub "$dest/ssh_host_ed25519_key.pub"
  echo "  host key      -> $dest/ssh_host_ed25519_key{,.pub}"

  if [[ -f "$user_age_key" ]]; then
    install -m 0600 "$user_age_key" "$dest/user-age-key.txt"
    echo "  user age key  -> $dest/user-age-key.txt"
  else
    echo "  (no $user_age_key — skipping user age key)"
  fi

  echo
  echo "done. Backup saved in: $dest"
  echo
  echo "During the real install, point the installer at it:"
  echo "  sudo HOST_KEY_SRC=$dest ./install/aspire7.sh"
  echo
  echo "note: FAT/exFAT filesystems do not enforce POSIX permissions (0600)."
}

if [[ -n "$DEST_ARG" ]]; then
  backup_to "$DEST_ARG"
  exit 0
fi

# --- interactive: detect removable drives and let the user pick one ---------

mount_point_of() { # $1 = disk name -> echo mountpoint (or nothing)
  lsblk -r -n -o NAME,MOUNTPOINT "/dev/$1" 2>/dev/null |
    awk '$2 != "" { mp = $2 } END { print mp }'
}

usable_dev_of() { # $1 = disk name -> echo first mountable dev (or nothing)
  lsblk -r -n -o NAME,FSTYPE "/dev/$1" 2>/dev/null |
    awk '
      $2 ~ /^(vfat|exfat|ntfs|ext2|ext3|ext4|btrfs|xfs)$/ { print $1; exit }
    '
}

declare -a names sizes models
while read -r name rm size model; do
  [[ $rm == "1" ]] || continue
  names+=("$name")
  sizes+=("$size")
  models+=("$model")
done < <(lsblk -d -r -n -o NAME,RM,SIZE,MODEL)

if ((${#names[@]} == 0)); then
  echo "error: no removable storage detected." >&2
  echo "  Plug in a USB stick and re-run, or pass an explicit destination:" >&2
  echo "  sudo bash install/backup-host-key.sh /path/to/backup" >&2
  exit 1
fi

if [[ ! -t 0 ]]; then
  echo "error: no destination given and stdin is not a terminal." >&2
  echo "  Pass one explicitly: sudo bash install/backup-host-key.sh /path/to/backup" >&2
  exit 1
fi

labels=()
for i in "${!names[@]}"; do
  mp=$(mount_point_of "${names[$i]}")
  if [[ -n "$mp" ]]; then
    minfo="mounted at $mp"
  elif [[ -n "$(usable_dev_of "${names[$i]}")" ]]; then
    minfo="not mounted (will mount)"
  else
    minfo="no usable filesystem"
  fi
  labels+=("/dev/${names[$i]}  ${sizes[$i]}  ${models[$i]}  — $minfo")
done

echo "Removable storage found:"
PS3="Pick a device [1-${#names[@]}]: "
select _ in "${labels[@]}"; do
  if [[ -n "$REPLY" ]] && ((REPLY >= 1 && REPLY <= ${#names[@]})); then
    idx=$((REPLY - 1))
    break
  fi
  echo "invalid choice, try again"
done

disk="${names[$idx]}"
mp=$(mount_point_of "$disk")
if [[ -z "$mp" ]]; then
  mdev=$(usable_dev_of "$disk")
  if [[ -z "$mdev" ]]; then
    echo "error: no mountable filesystem found on /dev/$disk" >&2
    exit 1
  fi
  mp="/mnt/backup-usb-$disk"
  mkdir -p "$mp"
  echo "==> mounting /dev/$mdev at $mp ..."
  mount "/dev/$mdev" "$mp"
  mounted_by_us=1
fi

backup_to "$mp/ssh-host-key-backup"

if [[ -n "${mounted_by_us:-}" ]]; then
  echo "==> unmounting $mp ..."
  umount "$mp"
fi
