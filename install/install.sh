#!/usr/bin/env bash
# Automated installation for any host in the flake, via nixos-anywhere.
#
# Usage (a host needs hosts/<hostname>/default.nix and hosts/<hostname>/disko.nix):
#   ./install/install.sh <hostname> --target <user>@<host>      # install a machine over SSH
#   ./install/install.sh <hostname> --target <user>@localhost   # kexec self-install
#   [--ssh-port N] [extra nixos-anywhere args...]
#
# The target user needs passwordless sudo (nixos-anywhere requirement).
# HOST_KEY_SRC defaults to the repo's secrets/ dir (see key-backup.sh).
#
# --minimal installs the console-TTY variant of the host (flake config
# .#<hostname>-min, profile = "minimal"): no display server, Wayland stack, or
# GUI apps. Defaults to the full desktop profile.
#
# The default target is nixos@localhost, which only exists when this script
# runs on a NixOS installer ISO; that ISO's RAM-backed store can't hold the
# desktop profile, so passing --target from an existing NixOS machine is the
# supported flow (see docs/installation.md). Every other argument is forwarded
# to nixos-anywhere unchanged.
#
# nixos-anywhere runs the `disko,install` phases: it wipes and repartitions the
# target disk (from hosts/<hostname>/disko.nix), regenerates the UUID-free
# hardware-configuration.nix, restores the SSH host key via --extra-files, and
# installs the system; but does not reboot, so /mnt stays mounted.
#
# Safety gates before anything destructive:
#   1. Aborts unless the host key backup exists (see key-backup.sh).
#   2. Aborts if the backup host key cannot decrypt secrets/secrets.yaml (sops).
#      Set SKIP_SOPS_CHECK=1 to bypass (e.g. throwaway-key VM rehearsals).
#   3. Requires typing 'yes' to confirm the disk wipe.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="${1:-aspire7}"
shift || true

MINIMAL=0
TARGET_HOST="nixos@localhost"
SSH_PORT=""
TARGET_GIVEN=0
PASS_ARGS=()
while (($# > 0)); do
  case "$1" in
    --target | --target-host)
      TARGET_GIVEN=1
      TARGET_HOST="$2"
      shift 2
      ;;
    --ssh-port)
      SSH_PORT="$2"
      shift 2
      ;;
    --minimal)
      MINIMAL=1
      shift
      ;;
    *)
      PASS_ARGS+=("$1")
      shift
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

if [[ -z $SSH_PORT && $TARGET_HOST == *:* ]]; then
  SSH_PORT="${TARGET_HOST##*:}"
  TARGET_HOST="${TARGET_HOST%:*}"
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

# Self-install (localhost target): the system is built ON the ISO by root, so
# the flake's build caches (e.g. nyx-cache.chaotic.cx) must be configured for
# root; nixos-anywhere only writes them to the *nixos* user's nix config on a
# remote target, which the local root build never reads. Without this the
# CachyOS kernel etc. would be compiled from source on the ISO.
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

target_host_part="${TARGET_HOST#*@}"
SELF_INSTALL=0
case "$target_host_part" in
  localhost | 127.0.0.1 | ::1)
    if [[ $TARGET_GIVEN != 1 ]]; then
      SELF_INSTALL=1
      if [[ $EUID -ne 0 ]]; then
        echo "Error: self-install to $target_host_part must be run as root (or with sudo)." >&2
        echo "  Root is only required for the default self-install (no --target)." >&2
        echo "  For remote/VM targets use --target <host> (no root needed)." >&2
        exit 1
      fi
    fi
    ;;
esac

HOST_KEY_SRC="${HOST_KEY_SRC:-$PWD/secrets}"

tmp=$(mktemp)
extra=$(mktemp -d)
keytmp=$(mktemp -d)
trap 'rm -f "$tmp"; rm -rf "$extra" "$keytmp"' EXIT

# The backup may be the age-passphrase blob committed by key-backup.sh;
# decrypt it into a staging dir here. A wrong passphrase aborts before the
# wipe; a plaintext dir (HOST_KEY_SRC given explicitly) is used as-is.
if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" && -d $HOST_KEY_SRC ]]; then
  # key-backup.sh names the blob after the machine hostname, which can
  # differ from the flake host; fall back to any single blob in the dir.
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
    echo "==> Decrypting key backup ($backup) ..."
    nix --experimental-features "nix-command flakes" run .#age -- -d -o "$keytmp/key-backup.tar" "$backup"
    tar -xzf "$keytmp/key-backup.tar" -C "$keytmp"
    HOST_KEY_SRC="$keytmp"
  fi
fi

if [[ ! -f "$HOST_KEY_SRC/ssh_host_ed25519_key" ]]; then
  echo "Error: host key backup not found at $HOST_KEY_SRC." >&2
  echo "  Reinstall? Back it up on the current system FIRST; this install wipes the disk:" >&2
  echo "    sudo bash install/key-backup.sh encrypt   # age passphrase, commits + pushes" >&2
  echo "  The installer then finds the backup automatically: by host, by" >&2
  echo "  hostname, or any secrets/key-backup-*.tar.age if names differ." >&2
  echo "  Brand-new host with nothing to back up? Install a fresh key instead:" >&2
  echo '    ssh-keygen -t ed25519 -N "" -f /tmp/newhost-key/ssh_host_ed25519_key' >&2
  echo "    SKIP_SOPS_CHECK=1 HOST_KEY_SRC=/tmp/newhost-key $0 $HOST" >&2
  exit 1
fi

if [[ ${SKIP_SOPS_CHECK:-0} != 1 && -f secrets/secrets.yaml ]]; then
  echo "==> [1/4] Verifying sops decryption from the backup host key..."
  if nix --experimental-features "nix-command flakes" run .#ssh-to-age -- \
    -private-key -i "$HOST_KEY_SRC/ssh_host_ed25519_key" >"$tmp" \
    && chmod 600 "$tmp" \
    && SOPS_AGE_KEY_FILE="$tmp" nix --experimental-features "nix-command flakes" run \
      .#sops -- -d "$(realpath secrets/secrets.yaml)" >/dev/null; then
    echo "  decryption ok"
  else
    echo "Error: backup host key cannot decrypt secrets/secrets.yaml." >&2
    echo "  Aborting before the wipe; fix HOST_KEY_SRC or run" >&2
    echo "  install/init-secrets.sh to register this host first." >&2
    exit 1
  fi
elif [[ -f secrets/secrets.yaml ]]; then
  echo "==> [1/4] Skipping sops decryption check (SKIP_SOPS_CHECK=1)."
else
  echo "==> [1/4] no secrets/secrets.yaml in this repo; skipping"
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

# Stage the sops decryption identity (host key) and root's safe.directory into
# the tree nixos-anywhere copies to the root (/) of the new system.
install -d -m 0755 "$extra/etc/ssh"
install -m 0600 "$HOST_KEY_SRC/ssh_host_ed25519_key" "$extra/etc/ssh/ssh_host_ed25519_key"
install -m 0644 "$HOST_KEY_SRC/ssh_host_ed25519_key.pub" "$extra/etc/ssh/ssh_host_ed25519_key.pub"
install -d -m 0700 "$extra/root"
printf '[safe]\n\tdirectory = *\n' >"$extra/root/.gitconfig"
chmod 0600 "$extra/root/.gitconfig"

echo "==> [2/4] Running nixos-anywhere (phases: disko,install); target: $TARGET_HOST"
# Real self-install (no --target): the build machine IS the ISO. The VM
# rehearsal targets localhost too (with --target + a forwarding port), but the
# build runs there on the already-cached invoking machine; skip.
if [[ $SELF_INSTALL == 1 ]]; then
  echo "  self-install: bootstrapping the ISO's root nix config with the flake build caches..."
  bootstrap_local_nix_cache
fi
# shellcheck disable=SC2054 # --phases is one comma-separated option, not an array
nixos_anywhere_args=(
  --flake ".#$CFG"
  --target-host "$TARGET_HOST"
  --extra-files "$extra"
  --generate-hardware-config nixos-generate-config "./hosts/$HOST/hardware-configuration.nix"
)
# ISO self-install runs from a RAM-backed store, so the disk is already free
# and disko can repartition it directly.  Running from an installed NixOS on
# the target disk requires kexec first: it boots into a minimal RAM Linux,
# freeing the disk for disko.
if [[ $SELF_INSTALL == 1 ]]; then
  nixos_anywhere_args+=(--phases disko,install)
fi
if [[ -n $SSH_PORT ]]; then
  nixos_anywhere_args+=(--ssh-port "$SSH_PORT")
fi
nixos_anywhere_args+=("${PASS_ARGS[@]}")

nix --experimental-features "nix-command flakes" run .#nixos-anywhere -- "${nixos_anywhere_args[@]}"

echo "==> [3/4] Setting safe.directory for root on the new system..."
if [[ -d /mnt/root ]]; then
  install -d -m 0700 /mnt/root
  printf '[safe]\n\tdirectory = *\n' >/mnt/root/.gitconfig
  chmod 0600 /mnt/root/.gitconfig
  echo "  wrote /mnt/root/.gitconfig (safe.directory = *); no sudo rebuild friction"
else
  echo "  target's /mnt is not local (remote install); root safe.directory was"
  echo "  already written into the new root via --extra-files."
fi

echo "==> [4/4] Installation complete!"
echo
echo "Installed profile: $CFG ($([ $MINIMAL == 1 ] && echo 'minimal; console TTY, no display server' || echo 'full; desktop'))."
echo "Self-install: reboot into NixOS with: reboot"
echo "Remote install: the target is already installed; reboot it."
echo
echo "After boot:"
echo "  1. Commit the regenerated hardware config (UUID-free; fileSystems come"
echo "     from disko.nix, so there is nothing to churn):"
echo "       cd /path/to/nixos-dots && git add hosts/$HOST/hardware-configuration.nix && git commit"
echo "     On a rehearsal host (vm) revert it instead; the VM-specific file is"
echo "     not the config you want committed:"
echo "       git checkout -- hosts/$HOST/hardware-configuration.nix"
echo "  2. The user's password is declarative: it's the sops-managed hash"
echo "     (secrets.yaml key user-password-hash). Change it there and rebuild;"
echo "     on throwaway hosts without sops (vm) it's the fixed initialPassword."
echo "  3. Restore the user keys if wanted (interactive sops edits + ssh client"
echo "     key; activation already uses the restored host key):"
echo "       bash install/key-backup.sh decrypt"
echo "  4. Verify sops secrets decrypted:"
echo "       ls -l ~/.config/opencode/context7-key ~/.config/opencode/github-token"
