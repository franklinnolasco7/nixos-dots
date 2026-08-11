#!/usr/bin/env bash
# Helper script to rebuild NixOS flake configuration.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="aspire7"
ACTION="switch"

# Allow passing action (e.g. boot, test) or flags
if [[ $# -gt 0 ]]; then
  if [[ $1 == "boot" || $1 == "test" || $1 == "switch" ]]; then
    ACTION="$1"
    shift
  fi
fi

echo "==> Rebuilding NixOS system configuration (#$HOST, action: $ACTION)..."
sudo nixos-rebuild "$ACTION" --flake ".#$HOST" "$@"
