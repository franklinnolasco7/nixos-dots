#!/usr/bin/env bash
# General entrypoint script for installing NixOS dotfiles.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="${1:-aspire7}"

if [[ ! -f "hosts/$HOST/default.nix" ]]; then
  echo "Error: Host configuration 'hosts/$HOST' not found." >&2
  exit 1
fi

if [[ ! -f "install/$HOST.sh" ]]; then
  echo "Error: Installation script 'install/$HOST.sh' not found." >&2
  exit 1
fi

echo "==> Running installer for host: $HOST"
exec bash "install/$HOST.sh"
