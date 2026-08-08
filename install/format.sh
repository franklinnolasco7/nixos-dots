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
  files=$(find . -type f -name "*.$ext" -not -path "./.git/*")
  if [[ -z "$files" ]]; then
    echo "[skip] no .$ext files"
    continue
  fi

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
    echo "[skip] $cmd not installed (run: nix-shell)"
    continue
  fi

  echo "[$cmd] $mode"
  case "$ext:$mode" in
    nix:check) "$cmd" --check "$files" ;;
    nix:write) "$cmd" "$files" ;;
    lua:check) "$cmd" --check "$files" ;;
    lua:write) "$cmd" "$files" ;;
    sh:check) "$cmd" -i 2 -ci -bn -s -d "$files" ;;
    sh:write) "$cmd" -i 2 -ci -bn -s -w "$files" ;;
    toml:check) "$cmd" fmt --check "$files" ;;
    toml:write) "$cmd" fmt "$files" ;;
  esac
done