#!/usr/bin/env bash
# Helper script to update flake inputs and rebuild NixOS.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Updating flake inputs..."
nix flake update

echo "==> Rebuilding NixOS system configuration (#aspire7)..."
exec bash install/rebuild.sh "$@"
