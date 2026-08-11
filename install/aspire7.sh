#!/usr/bin/env bash
# Automated installation script for Aspire 7 target hardware.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ $EUID -ne 0 ]]; then
  echo "Error: This script must be run as root (or with sudo)." >&2
  exit 1
fi

echo "==> [1/3] Partitioning and mounting disk with Disko..."
nix --experimental-features "nix-command flakes" run github:nix-community/disko#disko -- --mode disko ./hosts/aspire7/disko.nix

echo "==> [2/3] Installing NixOS system flake (#aspire7)..."
nixos-install --flake .#aspire7

echo "==> [3/3] Installation complete! Reboot into NixOS with: reboot"
