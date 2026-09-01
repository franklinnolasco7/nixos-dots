#!/usr/bin/env bash
# Install a host directly from the NixOS minimal ISO, without nixos-anywhere.
#
# Run this ON the booted installer ISO (after `nmtui` connects the network):
#   sudo ./install/iso-install.sh [host] [--minimal|--full]
#
# Defaults: host=aspire7, profile=minimal. Pass --full to install the full
# desktop directly, or switch to it after boot via nixos-rebuild.
#
# The script:
#   1. Bootstraps the nyx binary cache into root's nix.conf (CachyOS kernel).
#   2. Checks for a key backup (see key-backup.sh) and decrypts it.
#   3. Wipes + formats the disk with disko (prompts 'yes').
#   4. Generates the hardware config.
#   5. Runs nixos-install.
#   6. Stages the sops age key, SSH host key, and root's .gitconfig into
#      /nix/persist (impermanence bind-mounts them at boot).
#   7. Prints the reboot instruction.
#
# It does not set the login password; that's `passwd` after first boot.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="${1:-aspire7}"
shift || true

MINIMAL=1
for arg in "$@"; do
  case "$arg" in
    --minimal) MINIMAL=1 ;;
    --full) MINIMAL=0 ;;
    *)
      echo "Error: unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

# The -min suffix is a profile variant of an existing host; never a real
# hostname (see docs/architecture.md). The flake config is .#<host>-min; the
# host dir (disko, hardware config) stays the base <host>.
CFG="$HOST"
if [[ $MINIMAL == 1 ]]; then
  CFG="$HOST-min"
fi

if [[ ! -f "hosts/$HOST/default.nix" ]]; then
  echo "Error: host config 'hosts/$HOST/default.nix' not found." >&2
  echo "  Hosts: $(ls hosts 2>/dev/null | tr '\n' ' ')" >&2
  exit 1
fi

if [[ ! -f "hosts/$HOST/disko.nix" ]]; then
  echo "Error: disk layout 'hosts/$HOST/disko.nix' not found." >&2
  echo "  Add one for this host before installing." >&2
  exit 1
fi

# The flake build runs as root on the ISO, so root needs the flake's binary
# caches (e.g. nyx-cache.chaotic.cx); without this the CachyOS kernel builds
# from source on the ISO.
bootstrap_local_nix_cache() {
  local conf=/root/.config/nix/nix.conf
  local sub keys
  sub=$(nix --experimental-features "nix-command flakes" eval --raw --apply toString \
    "#nixosConfigurations.\"${CFG}\".config.nix.settings.substituters")
  keys=$(nix --experimental-features "nix-command flakes" eval --raw --apply toString \
    "#nixosConfigurations.\"${CFG}\".config.nix.settings.trusted-public-keys")
  mkdir -p "$(dirname "$conf")"
  touch "$conf"
  grep -q '^extra-substituters' "$conf" || echo "extra-substituters = $sub" >>"$conf"
  grep -q '^extra-trusted-public-keys' "$conf" || echo "extra-trusted-public-keys = $keys" >>"$conf"
  echo "  wrote $conf (build cache: $sub)"
}

echo "==> [1/6] Bootstrapping root's nix config with the flake build caches..."
bootstrap_local_nix_cache

HOST_KEY_SRC="${HOST_KEY_SRC:-$PWD/secrets}"
keytmp=$(mktemp -d)
trap 'rm -rf "$keytmp"' EXIT

# The backup may be the age-passphrase blob committed by key-backup.sh;
# decrypt it into a staging dir here. A wrong passphrase aborts before the
# wipe; a plaintext dir (HOST_KEY_SRC given explicitly) is used as-is.
if [[ ! -f "$HOST_KEY_SRC/sops-age-key.txt" && -d $HOST_KEY_SRC ]]; then
  backup=
  for candidate in "$HOST_KEY_SRC/key-backup-$HOST.tar.age" "$HOST_KEY_SRC/key-backup-$(hostname).tar.age"; do
    if [[ -f $candidate ]]; then
      backup=$candidate
      break
    fi
  done
  if [[ -z $backup ]]; then
    blobs=("$HOST_KEY_SRC"/key-backup-*.tar.age)
    if ((${#blobs[@]} > 1)); then
      echo "Error: multiple key backups in $HOST_KEY_SRC and none named for $HOST." >&2
      printf '  %s\n' "${blobs[@]}" >&2
      echo "  Point HOST_KEY_SRC at the directory holding the right one." >&2
      exit 1
    fi
    if ((${#blobs[@]} == 1)) && [[ -f ${blobs[0]} ]]; then
      backup=${blobs[0]}
    fi
  fi
  if [[ -n $backup ]]; then
    echo "==> [2/6] Decrypting key backup ($backup) ..."
    echo "  (sops age key + SSH host key; user keys restore after boot: bash install/key-backup.sh decrypt)"
    nix --experimental-features "nix-command flakes" run .#age -- -d -o "$keytmp/key-backup.tar" "$backup"
    tar -xzf "$keytmp/key-backup.tar" -C "$keytmp"
    HOST_KEY_SRC="$keytmp"
  fi
fi

if [[ ! -f "$HOST_KEY_SRC/sops-age-key.txt" ]]; then
  echo "Error: dedicated sops age key (sops-age-key.txt) not found at $HOST_KEY_SRC." >&2
  echo "  Back it up on the current system FIRST; this install wipes the disk:" >&2
  echo "    sudo bash install/key-backup.sh encrypt   # age passphrase, commits + pushes" >&2
  exit 1
fi

if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" ]]; then
  echo "Error: SSH host key (ssh_host_ed25519_key) not found at $HOST_KEY_SRC." >&2
  exit 1
fi

disko_dev="$(sed -n 's/.*device = \(lib\.mkDefault \)\?"\([^"]*\)".*/\2/p' "hosts/$HOST/disko.nix" | head -1)"
resolved="$(readlink -f "$disko_dev" 2>/dev/null || true)"
if [[ -n $resolved && $resolved != "$disko_dev" ]]; then
  disko_dev="$disko_dev ($resolved)"
fi

echo
echo "  !!! IMPORTANT !!!"
echo "  This will DESTROY all data on: $disko_dev"
echo "  (key backup verified at: $HOST_KEY_SRC)"
read -rp "  Type 'yes' to wipe and continue, anything else to abort: " answer
if [[ $answer != "yes" ]]; then
  echo "Aborted."
  exit 1
fi
echo

echo "==> [3/6] Running disko (destroy,format,mount)..."
nix --experimental-features "nix-command flakes" run .#disko -- \
  --mode destroy,format,mount "hosts/$HOST/disko.nix"

echo "==> [4/6] Generating the hardware config (UUID-free)..."
nixos-generate-config --no-filesystems --root /mnt
install -m 0644 /mnt/etc/nixos/hardware-configuration.nix "hosts/$HOST/hardware-configuration.nix"

echo "==> [5/6] Running nixos-install..."
nixos-install --flake ".#$CFG" --no-root-passwd

echo "==> [6/6] Staging keys into the persist dir..."
# Root is tmpfs (see modules/disko/gpt-layout.nix); /etc and /root vanish on
# reboot, so impermanence bind-mounts these from /nix/persist at boot.
install -d -m 0700 /mnt/nix/persist/etc/sops-nix
install -m 0600 "$HOST_KEY_SRC/sops-age-key.txt" /mnt/nix/persist/etc/sops-nix/keys.txt
install -d -m 0755 /mnt/nix/persist/etc/ssh
install -m 0600 "$HOST_KEY_SRC/ssh_host_ed25519_key" /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key
install -m 0644 "$HOST_KEY_SRC/ssh_host_ed25519_key.pub" /mnt/nix/persist/etc/ssh/ssh_host_ed25519_key.pub
install -d -m 0700 /mnt/nix/persist/root
printf '[safe]\n\tdirectory = *\n' >/mnt/nix/persist/root/.gitconfig
chmod 0600 /mnt/nix/persist/root/.gitconfig

echo
echo "Installation complete! Profile: $CFG."
echo "  Reboot with: reboot   (remove the USB when the screen goes black)"
echo "After boot:"
echo "  1. Unlock the LUKS persist disk, log in as your user."
echo "  2. Clone the repo and commit the regenerated hardware config:"
echo "       git clone https://github.com/franklinnolasco7/nixos-dots.git && cd nixos-dots"
echo "       git add hosts/$HOST/hardware-configuration.nix && git commit"
echo "  3. Restore the user keys before the first signed commit:"
echo "       bash install/key-backup.sh decrypt"
echo "  4. Switch to the full desktop profile (if you installed minimal):"
echo "       sudo nixos-rebuild switch --flake .#$HOST"
