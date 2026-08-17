#!/usr/bin/env bash
# Encrypt this machine's keys into the repo; the pre-wipe backup.
#
# Usage:
#   sudo bash install/key-backup.sh encrypt [--no-push]
#   bash install/key-backup.sh decrypt [--dir DIR]
#
# encrypt packs the sops decryption identities into
# secrets/key-backup-<hostname>.tar.age (age passphrase mode, scrypt) and
# commits + pushes the blob (unsigned: it runs as root). The passphrase is the
# only secret you must keep.
# Put it in a password manager; lose it and the backup is useless. The blob is
# safe to commit even to a public repo. --no-push skips the push (offline).
#
# decrypt prompts for the passphrase and either extracts the archive to DIR
# (--dir) or restores the user keys into the current home directory.
#
# The archive contains (missing files are skipped with a warning):
#   1. /etc/ssh/ssh_host_ed25519_key{,.pub}; the sops age identity; a fresh
#      install regenerates it, making committed secrets unreadable without it.
#   2. ~/.config/sops/age/keys.txt; user age key (interactive sops editing).
#   3. ~/.ssh/id_ed25519{,.pub}; the user's SSH client / git-signing key.
#
# install.sh consumes the blob automatically: with HOST_KEY_SRC pointing at the
# repo's secrets/ dir it prompts for the passphrase and decrypts before the
# wipe; see docs/secrets.md.
set -euo pipefail

cd "$(dirname "$0")/.."

MODE="${1:-}"
shift || true

NO_PUSH=0
DECRYPT_DIR=""
case "$MODE" in
  encrypt)
    if [[ ${1:-} == "--no-push" ]]; then
      NO_PUSH=1
    fi
    ;;
  decrypt)
    if [[ ${1:-} == "--dir" ]]; then
      DECRYPT_DIR="${2:?usage: decrypt --dir DIR}"
    fi
    ;;
  *)
    printf '%s\n' \
      'usage:' \
      '  sudo bash install/key-backup.sh encrypt [--no-push]' \
      '  bash install/key-backup.sh decrypt [--dir DIR]' >&2
    exit 1
    ;;
esac

host="$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')"
backup_file="secrets/key-backup-$host.tar.age"

# Prefer this host's blob; fall back to any other key-backup-*.tar.age in
# secrets/ (e.g. a new hostname after a reinstall).
backup_of() {
  if [[ -f $backup_file ]]; then
    printf '%s' "$backup_file"
    return
  fi
  local candidate
  for candidate in "$(dirname "$backup_file")"/key-backup-*.tar.age; do
    if [[ -f $candidate ]]; then
      printf '%s' "$candidate"
      return
    fi
  done
}

age() {
  nix --experimental-features "nix-command flakes" run .#age -- "$@"
}

if [[ $MODE == encrypt ]]; then
  if [[ $EUID -ne 0 ]]; then
    echo "error: encrypt must run as root (sudo); reads /etc/ssh" >&2
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

  stage=$(mktemp -d)
  trap 'rm -rf "$stage"' EXIT

  install -m 0600 /etc/ssh/ssh_host_ed25519_key "$stage/ssh_host_ed25519_key"
  install -m 0644 /etc/ssh/ssh_host_ed25519_key.pub "$stage/ssh_host_ed25519_key.pub"
  echo "  host key     -> $stage/ssh_host_ed25519_key{,.pub}"

  include=(ssh_host_ed25519_key ssh_host_ed25519_key.pub)
  if [[ -f $user_age_key ]]; then
    install -m 0600 "$user_age_key" "$stage/user-age-key.txt"
    echo "  user age key -> $stage/user-age-key.txt"
    include+=(user-age-key.txt)
  else
    echo "  (no $user_age_key; skipping user age key)"
  fi

  if [[ -f "$user_home/.ssh/id_ed25519" ]]; then
    install -m 0600 "$user_home/.ssh/id_ed25519" "$stage/id_ed25519"
    install -m 0644 "$user_home/.ssh/id_ed25519.pub" "$stage/id_ed25519.pub"
    echo "  user ssh key -> $stage/id_ed25519{,.pub}"
    include+=(id_ed25519 id_ed25519.pub)
  else
    echo "  (no $user_home/.ssh/id_ed25519; skipping user ssh key)"
  fi

  tar -czf "$stage/key-backup.tar" -C "$stage" "${include[@]}"

  mkdir -p "$(dirname "$backup_file")"
  echo
  age -p -o "$backup_file" "$stage/key-backup.tar"
  echo "  encrypted    -> $backup_file"

  # The commit runs as root, which has no git identity; carry the real user's
  # over via env (per-invocation, no config pollution). Unsigned by design:
  # root has no signing key, and the blob is encrypted data anyway.
  git_user_name="$(sudo -u "$real_user" git config --get user.name 2>/dev/null || true)"
  git_user_email="$(sudo -u "$real_user" git config --get user.email 2>/dev/null || true)"
  GIT_AUTHOR_NAME="${git_user_name:-$real_user}"
  GIT_AUTHOR_EMAIL="${git_user_email:-$real_user@$host}"
  GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
  GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
  export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL

  git add "$backup_file"
  if git diff --cached --quiet -- "$backup_file"; then
    echo "  nothing new to commit"
  else
    git -c commit.gpgsign=false commit -o "$backup_file" -m "chore(secrets): refresh $host key backup"
    if [[ $NO_PUSH == 0 ]]; then
      git push || {
        echo "error: push failed; the backup is only local, and the disk is" >&2
        echo "  about to be wiped. Fix the remote and re-push, or accept the" >&2
        echo "  risk and re-run with --no-push." >&2
        exit 1
      }
    fi
  fi

  echo
  echo "done. The installer picks this up automatically (install command and"
  echo "flow: docs/installation.md)."
  echo "(decryption prompts for the backup passphrase)"
elif [[ $MODE == decrypt ]]; then
  file="$(backup_of || true)"
  if [[ -z $file ]]; then
    echo "error: no key backup found in secrets/; clone the repo containing" >&2
    echo "  the blob first (the machine's own backup is pushed there)." >&2
    exit 1
  fi

  stage=$(mktemp -d)
  trap 'rm -rf "$stage"' EXIT

  age -d -o "$stage/key-backup.tar" "$file"
  tar -xzf "$stage/key-backup.tar" -C "$stage"

  if [[ -n $DECRYPT_DIR ]]; then
    mkdir -p "$DECRYPT_DIR"
    cp -a "$stage"/. "$DECRYPT_DIR"/
    echo "done. Keys extracted to $DECRYPT_DIR; use it as HOST_KEY_SRC."
    exit 0
  fi

  restore() {
    local src="$1" dst="$2" perm="$3"
    if [[ ! -f $src ]]; then
      return
    fi
    if [[ -e $dst ]] && ! cmp -s "$src" "$dst"; then
      read -rp "overwrite existing $(basename "$dst")? [y/N] " yn
      if [[ $yn != [yY] ]]; then
        echo "  skipped $(basename "$dst")"
        return
      fi
    fi
    install -d -m 0700 "$(dirname "$dst")"
    install -m "$perm" "$src" "$dst"
    echo "  restored $(basename "$dst")"
  }

  restore "$stage/user-age-key.txt" "$HOME/.config/sops/age/keys.txt" 0600
  restore "$stage/id_ed25519" "$HOME/.ssh/id_ed25519" 0600
  restore "$stage/id_ed25519.pub" "$HOME/.ssh/id_ed25519.pub" 0644
  echo "done."
fi
