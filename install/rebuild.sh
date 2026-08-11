#!/usr/bin/env bash
# Helper script to rebuild NixOS flake configuration.
#
# Usage:
#   install/rebuild.sh                       # switch aspire7 (default)
#   install/rebuild.sh boot                  # action on default host
#   install/rebuild.sh <host>                # switch on <host>
#   install/rebuild.sh <host> <action>       # action on <host>
#   install/rebuild.sh ... -- <flags>
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="aspire7"
ACTION="switch"

# Arg detection: a hosts/<name>/ dir means <host>; an action word means ACTION.
if [[ $# -gt 0 ]]; then
  if [[ -f "hosts/$1/default.nix" ]]; then
    HOST="$1"
    shift
  fi
  if [[ $# -gt 0 && $1 =~ ^(boot|test|switch|build|dry-build)$ ]]; then
    ACTION="$1"
    shift
  fi
fi

echo "==> Rebuilding NixOS system configuration (#$HOST, action: $ACTION)..."
sudo nixos-rebuild "$ACTION" --flake ".#$HOST" "$@"
