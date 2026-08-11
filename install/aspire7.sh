#!/usr/bin/env bash
# Automated installation script for Aspire 7 target hardware.
#
# Prerequisites:
#   - NixOS minimal ISO, cloned repo, internet.
#   - SSH host key backed up with install/backup-host-key.sh (sops secrets).
#
# Usage:
#   sudo HOST_KEY_SRC=/path/to/backup ./install/aspire7.sh
#   HOST_KEY_SRC defaults to /root/ssh-host-key-backup.
#
# Safety gates before anything destructive:
#   1. Aborts unless the host key backup exists (see backup-host-key.sh).
#   2. Requires typing 'yes' to confirm the disk wipe.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (or with sudo)." >&2
  exit 1
fi

HOST_KEY_SRC="${HOST_KEY_SRC:-/root/ssh-host-key-backup}"

if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" ]]; then
  echo "Error: host key backup not found at $HOST_KEY_SRC." >&2
  echo "  Back it up on the current system FIRST — this install wipes the disk." >&2
  echo "    sudo bash install/backup-host-key.sh   # detects USB, saves the keys" >&2
  echo "  Then re-run with: sudo HOST_KEY_SRC=<backup-dir> $0" >&2
  exit 1
fi

disko_dev="$(sed -n 's/.*device = "\([^"]*\)".*/\1/p' hosts/aspire7/disko.nix | head -1)"
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

echo "==> [1/5] Partitioning and mounting disk with Disko (pinned via flake)..."
nix --experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount ./hosts/aspire7/disko.nix

echo "==> [2/5] Regenerating hardware-configuration.nix for the new partitions..."
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/aspire7/hardware-configuration.nix
echo "  wrote hosts/aspire7/hardware-configuration.nix (new filesystem UUIDs)"

echo "==> [3/5] Restoring SSH host key for sops decryption..."
install -d -m 0700 /mnt/etc/ssh
install -m 0600 "$HOST_KEY_SRC/ssh_host_ed25519_key" /mnt/etc/ssh/ssh_host_ed25519_key
install -m 0644 "$HOST_KEY_SRC/ssh_host_ed25519_key.pub" /mnt/etc/ssh/ssh_host_ed25519_key.pub
echo "  restored /etc/ssh/ssh_host_ed25519_key{,.pub} into the new system"

echo "==> [4/5] Installing NixOS system flake (#aspire7)..."
nixos-install --flake .#aspire7

echo "==> [5/5] Installation complete! Reboot into NixOS with: reboot"
echo
echo "After reboot:"
echo "  1. Commit the regenerated hardware config:"
echo "       cd $(pwd) && git add hosts/aspire7/hardware-configuration.nix && git commit"
echo "  2. Change frank's password (initialPassword is 'changeme'):"
echo "       passwd frank"
echo "  3. Restore the user age key if wanted:"
echo "       install -m 0600 $HOST_KEY_SRC/user-age-key.txt ~/.config/sops/age/keys.txt"
echo "  4. Verify sops secrets decrypted:"
echo "       ls -l ~/.config/opencode/context7-key ~/.config/opencode/github-token"
