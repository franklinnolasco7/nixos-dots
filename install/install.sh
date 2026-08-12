#!/usr/bin/env bash
# Automated installation for any host in the flake.
#
# Usage:
#   sudo ./install/install.sh <hostname>
#   sudo HOST_KEY_SRC=/path/to/backup ./install/install.sh <hostname>
#
# <hostname> needs hosts/<hostname>/default.nix and hosts/<hostname>/disko.nix.
# HOST_KEY_SRC defaults to /root/ssh-host-key-backup (see backup-host-key.sh).
#
# Safety gates before anything destructive:
#   1. Aborts unless the host key backup exists (see backup-host-key.sh).
#   2. Aborts if the backup host key cannot decrypt secrets/secrets.yaml (sops).
#   3. Requires typing 'yes' to confirm the disk wipe.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="${1:-aspire7}"

if [[ ! -f "hosts/$HOST/default.nix" ]]; then
  echo "Error: host config 'hosts/$HOST/default.nix' not found." >&2
  echo "  Hosts: $(ls hosts 2>/dev/null | tr '\n' ' ')" >&2
  exit 1
fi

if [[ ! -f "hosts/$HOST/disko.nix" ]]; then
  echo "Error: disk layout 'hosts/$HOST/disko.nix' not found." >&2
  echo "  Add one for this host before installing." >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (or with sudo)." >&2
  exit 1
fi

HOST_KEY_SRC="${HOST_KEY_SRC:-/root/ssh-host-key-backup}"

if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" ]]; then
  echo "Error: host key backup not found at $HOST_KEY_SRC." >&2
  echo "  Back it up on the current system FIRST — this install wipes the disk." >&2
  echo "    sudo bash install/backup-host-key.sh   # detects USB, saves the keys" >&2
  echo "  Then re-run with: sudo HOST_KEY_SRC=<backup-dir> $0 $HOST" >&2
  exit 1
fi

echo "==> [0/6] Verifying sops decryption from the backup host key..."
if [[ -f secrets/secrets.yaml ]]; then
  tmp=$(mktemp)
  trap 'rm -f "$tmp"' EXIT
  if nix --experimental-features "nix-command flakes" shell nixpkgs#ssh-to-age \
    -c ssh-to-age -private-key -i "$HOST_KEY_SRC/ssh_host_ed25519_key" >"$tmp" \
    && chmod 600 "$tmp" \
    && SOPS_AGE_KEY_FILE="$tmp" nix --experimental-features "nix-command flakes" shell \
      nixpkgs#sops -c sops -d "$(realpath secrets/secrets.yaml)" >/dev/null; then
    echo "  decryption ok"
  else
    echo "Error: backup host key cannot decrypt secrets/secrets.yaml." >&2
    echo "  Aborting before the wipe — fix HOST_KEY_SRC or run" >&2
    echo "  install/init-secrets.sh to register this host first." >&2
    exit 1
  fi
else
  echo "  no secrets/secrets.yaml in this repo — skipping"
fi

disko_dev="$(sed -n 's/.*device = \(lib\.mkDefault \)\?"\([^"]*\)".*/\2/p' "hosts/$HOST/disko.nix" | head -1)"
resolved="$(readlink -f "$disko_dev" 2>/dev/null || true)"
if [[ -n $resolved && $resolved != "$disko_dev" ]]; then
  disko_dev="$disko_dev ($resolved)"
fi

echo
echo "  !!! IMPORTANT !!!"
echo "  This will DESTROY all data on: $disko_dev"
echo "  (key backup verified at: $HOST_KEY_SRC)"
read -rp "  Type 'yes' to wipe and continue, anything else to abort: " answer
if [[ $answer != "yes" ]]; then
  echo "Aborted."
  exit 1
fi
echo

echo "==> [1/6] Partitioning and mounting disk with Disko (pinned via flake)..."
nix --experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount "hosts/$HOST/disko.nix"

echo "==> [2/6] Regenerating hardware-configuration.nix for the new partitions..."
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix "hosts/$HOST/hardware-configuration.nix"
echo "  wrote hosts/$HOST/hardware-configuration.nix (new filesystem UUIDs)"

echo "==> [3/6] Restoring SSH host key for sops decryption..."
install -d -m 0700 /mnt/etc/ssh
install -m 0600 "$HOST_KEY_SRC/ssh_host_ed25519_key" /mnt/etc/ssh/ssh_host_ed25519_key
install -m 0644 "$HOST_KEY_SRC/ssh_host_ed25519_key.pub" /mnt/etc/ssh/ssh_host_ed25519_key.pub
echo "  restored /etc/ssh/ssh_host_ed25519_key{,.pub} into the new system"

echo "==> [4/6] Installing NixOS system flake (.#$HOST)..."
nixos-install --flake ".#$HOST"

echo "==> [5/6] Setting safe.directory for root on the new system..."
if command -v git >/dev/null 2>&1; then
  install -d -m 0700 /mnt/root
  git config --file /mnt/root/.gitconfig --add safe.directory '*'
  echo "  wrote /mnt/root/.gitconfig (safe.directory = *) — no sudo rebuild friction"
else
  echo "  git not found — set safe.directory manually after reboot:"
  echo "    sudo git config --global --add safe.directory '*'"
fi

echo "==> [6/6] Installation complete! Reboot into NixOS with: reboot"
echo
echo "After reboot:"
echo "  1. Commit the regenerated hardware config:"
echo "       cd /path/to/nixos-dots && git add hosts/$HOST/hardware-configuration.nix && git commit"
echo "  2. Change your user's password (initialPassword is '123'):"
echo "       passwd <your-user>"
echo "  3. Restore the user age key if wanted:"
echo "       install -m 0600 $HOST_KEY_SRC/user-age-key.txt ~/.config/sops/age/keys.txt"
echo "  4. Verify sops secrets decrypted:"
echo "       ls -l ~/.config/opencode/context7-key ~/.config/opencode/github-token"
