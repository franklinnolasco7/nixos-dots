#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  check)
    mode="check"
    ;;
  *)
    mode="write"
    ;;
esac

for ext in nix lua sh toml; do
  case "$ext" in
    nix)
      cmd="nixfmt"
      ;;
    lua)
      cmd="stylua"
      ;;
    sh)
      cmd="shfmt"
      ;;
    toml)
      cmd="taplo"
      ;;
  esac

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[skip] $cmd not installed (run: nix develop)"
    continue
  fi

  echo "[$cmd] $mode"
  case "$ext:$mode" in
    nix:check) find . -type f -name "*.nix" -not -path "./.git/*" -exec "$cmd" --check {} + ;;
    nix:write) find . -type f -name "*.nix" -not -path "./.git/*" -exec "$cmd" {} + ;;
    lua:check) find . -type f -name "*.lua" -not -path "./.git/*" -exec "$cmd" --check {} + ;;
    lua:write) find . -type f -name "*.lua" -not -path "./.git/*" -exec "$cmd" {} + ;;
    sh:check) find . -type f -name "*.sh" -not -path "./.git/*" -exec "$cmd" -i 2 -ci -bn -s -d {} + ;;
    sh:write) find . -type f -name "*.sh" -not -path "./.git/*" -exec "$cmd" -i 2 -ci -bn -s -w {} + ;;
    toml:check) find . -type f -name "*.toml" -not -path "./.git/*" -exec "$cmd" fmt --check {} + ;;
    toml:write) find . -type f -name "*.toml" -not -path "./.git/*" -exec "$cmd" fmt {} + ;;
  esac
done
