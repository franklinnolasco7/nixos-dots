#!/usr/bin/env bash
# One-time bootstrap of sops-encrypted secrets for opencode.
#
# Run this ON THE NIXOS MACHINE after cloning/pulling the repo:
#   bash install/init-secrets.sh
#
# Prerequisites:
#   - nix is installed
#   - ~/.ssh/id_ed25519.pub exists and matches the key that encrypted
#     the age recipient in .sops.yaml
#   - gh is logged in (for the GitHub token)
#   - a Context7 API key (https://context7.com/dashboard); falls back
#     to $CONTEXT7_API_KEY, then prompts
set -euo pipefail

cd "$(dirname "$0")/.."

EXPECTED_PUBKEY="age1q969ujg7l62vgcg7df4jlnqa5unmuvczjulvfyx469ygk73lzzd5q"

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix not found — run this on the NixOS machine" >&2
  exit 1
fi

if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
  echo "error: $HOME/.ssh/id_ed25519.pub not found" >&2
  exit 1
fi

ssh-to-age() {
  nix shell nixpkgs#ssh-to-age -c ssh-to-age "$@"
}
sops() {
  nix shell nixpkgs#sops -c sops "$@"
}

echo "[1/5] checking age key matches .sops.yaml ..."
actual=$(ssh-to-age -i "$HOME/.ssh/id_ed25519.pub")
if [[ $actual != "$EXPECTED_PUBKEY" ]]; then
  echo "error: age key mismatch" >&2
  echo "  expected: $EXPECTED_PUBKEY" >&2
  echo "  actual:   $actual" >&2
  echo "  Use the same ~/.ssh/id_ed25519 on this machine, or update" >&2
  echo "  the recipient in .sops.yaml with 'ssh-to-age -i ~/.ssh/id_ed25519.pub'." >&2
  exit 1
fi
echo "  ok"

echo "[2/5] collecting Context7 API key ..."
if [[ -z ${CONTEXT7_API_KEY:-} ]]; then
  read -rp "  Context7 API key (https://context7.com/dashboard): " CONTEXT7_API_KEY
fi
if [[ -z $CONTEXT7_API_KEY ]]; then
  echo "error: no Context7 API key" >&2
  exit 1
fi

echo "[3/5] collecting GitHub token ..."
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  GITHUB_TOKEN="$(gh auth token)"
elif [[ -n ${GITHUB_TOKEN:-} ]]; then
  :
else
  read -rsp "  GitHub personal access token: " GITHUB_TOKEN
  echo
fi
if [[ -z $GITHUB_TOKEN ]]; then
  echo "error: no GitHub token" >&2
  exit 1
fi

echo "[4/5] encrypting secrets/secrets.yaml ..."
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
cat >"$tmpdir/secrets.json" <<EOF
{
  "context7-api-key": "$CONTEXT7_API_KEY",
  "github-token": "$GITHUB_TOKEN"
}
EOF
sops --input-type json --output-type yaml \
  --output secrets/secrets.yaml \
  "$tmpdir/secrets.json"
chmod 600 secrets/secrets.yaml

echo "[5/5] verifying decryption ..."
sops -d secrets/secrets.yaml >/dev/null
echo "  decryption ok"

echo
echo "done. Next steps on this machine:"
echo "  1. git add secrets/secrets.yaml .sops.yaml && git commit && git push"
echo "  2. sudo nixos-rebuild switch --flake .#aspire7"
echo "  3. opencode → /status → context7 and github should show connected"
