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
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (or with sudo)." >&2
  exit 1
fi

HOST_KEY_SRC="${HOST_KEY_SRC:-/root/ssh-host-key-backup}"

echo "==> [1/5] Partitioning and mounting disk with Disko (pinned via flake)..."
nix --experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount ./hosts/aspire7/disko.nix

echo "==> [2/5] Regenerating hardware-configuration.nix for the new partitions..."
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix hosts/aspire7/hardware-configuration.nix
echo "  wrote hosts/aspire7/hardware-configuration.nix (new filesystem UUIDs)"

echo "==> [3/5] Restoring SSH host key for sops decryption..."
if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" ]]; then
  echo "Error: host key backup not found at $HOST_KEY_SRC." >&2
  echo "  Back it up on the current system first:" >&2
  echo "    sudo bash install/backup-host-key.sh <dest-dir>" >&2
  echo "  Then re-run with: sudo HOST_KEY_SRC=<dest-dir> $0" >&2
  exit 1
fi
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
