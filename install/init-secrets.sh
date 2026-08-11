#!/usr/bin/env bash
# Multi-host sops bootstrap.
#
# Run this ON A NIXOS HOST after cloning/pulling the repo:
#   bash install/init-secrets.sh
#
# Actions (idempotent, safe to re-run):
#   1. Derive an age recipient from the host SSH key
#      (/etc/ssh/ssh_host_ed25519_key.pub).
#   2. Register this host's recipient in .sops.yaml if missing.
#   3. Create an encrypted skeleton secrets/secrets.yaml if absent.
#   4. Re-encrypt secrets/secrets.yaml to every registered host.
#
# Prerequisites:
#   - nix is installed (run on the NixOS host)
#   - host SSH key exists (always true on NixOS, services.openssh)
set -euo pipefail

cd "$(dirname "$0")/.."

HOST_KEY_PUB=/etc/ssh/ssh_host_ed25519_key.pub
SOPS_YAML=.sops.yaml
SECRETS_FILE=secrets/secrets.yaml

if ! command -v nix >/dev/null 2>&1; then
  echo "error: nix not found — run this on the NixOS host" >&2
  exit 1
fi

if [[ ! -f "$HOST_KEY_PUB" ]]; then
  echo "error: $HOST_KEY_PUB not found" >&2
  echo "  enable services.openssh or verify the host key path" >&2
  exit 1
fi

ssh-to-age() {
  nix shell nixpkgs#ssh-to-age -c ssh-to-age "$@"
}
sops() {
  nix shell nixpkgs#sops -c sops "$@"
}

echo "[1/4] deriving age recipient from host key ..."
recipient=$(ssh-to-age -i "$HOST_KEY_PUB")
anchor="host-$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')"
echo "  $anchor: $recipient"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

echo "[2/4] registering $anchor in $SOPS_YAML ..."
mapfile -t key_lines < <(grep -E '^\s*-\s+&' "$SOPS_YAML")
names=()
registered=false
replaced=false
for l in "${key_lines[@]}"; do
  read -r _ a rec <<<"$l"
  name=$(sed 's/^&//' <<<"$a")
  names+=("$name")
  if [[ $rec == "$recipient" ]]; then
    registered=true
  fi
  if [[ $name == "$anchor" ]]; then
    replaced=true
  fi
done

if [[ $registered == true ]]; then
  echo "  already registered"
else
  cat >"$tmpdir/sops.yaml" <<EOF
keys:
EOF
  for l in "${key_lines[@]}"; do
    read -r _ a rec <<<"$l"
    name=$(sed 's/^&//' <<<"$a")
    if [[ $name == "$anchor" ]]; then
      l="  - &$anchor $recipient"
    fi
    echo "$l"
  done >>"$tmpdir/sops.yaml"
  if [[ $replaced == false ]]; then
    echo "  - &$anchor $recipient" >>"$tmpdir/sops.yaml"
  fi
  echo "creation_rules:" >>"$tmpdir/sops.yaml"
  echo "  - path_regex: ^secrets/secrets\\.yaml\$" >>"$tmpdir/sops.yaml"
  age_list=""
  for n in "${names[@]}"; do
    [[ $n != "$anchor" ]] && age_list+="*$n, "
  done
  age_list+="*$anchor"
  echo "    age: [$age_list]" >>"$tmpdir/sops.yaml"

  if cmp -s "$tmpdir/sops.yaml" "$SOPS_YAML"; then
    echo "  no change needed"
  else
    cp "$SOPS_YAML" "$tmpdir/sops.yaml.bak"
    cp "$tmpdir/sops.yaml" "$SOPS_YAML"
    echo "  registered (backup: $tmpdir/sops.yaml.bak)"
  fi
fi

echo "[3/4] ensuring $SECRETS_FILE ..."
if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "  creating encrypted skeleton (empty values)"
  cat >"$tmpdir/secrets.json" <<EOF
{
  "context7-api-key": "",
  "github-token": ""
}
EOF
  sops --input-type json --output-type yaml \
    --output "$SECRETS_FILE" \
    "$tmpdir/secrets.json"
else
  echo "  re-encrypting to all registered hosts ..."
  sops updatekeys "$SECRETS_FILE"
fi
chmod 600 "$SECRETS_FILE"

echo "[4/4] verifying decryption ..."
sops -d "$SECRETS_FILE" >/dev/null
echo "  decryption ok"

echo
echo "done. Next steps on this machine:"
echo "  1. fill real values: sops $SECRETS_FILE"
echo "  2. git add .sops.yaml $SECRETS_FILE && git commit && git push"
echo "  3. sudo nixos-rebuild switch --flake .#HOSTNAME"
echo "  4. opencode → /status → context7 and github should show connected"