#!/usr/bin/env bash
# Boot the `vm` NixOS host in QEMU/KVM with UEFI (OVMF).
#
# With an ISO: boots the installer and targets install/install.sh vm.
# Without an ISO: boots the installed system from the disk image.
#
# Usage:
#   ./install/run-vm.sh [minimal-iso] [disk-image]
#
# Disk defaults to /tmp/nixos-vm.qcow2 (40G sparse, created if missing).
# The installed system is expected on /dev/vda (see hosts/vm/disko.nix).
# Port 2222 on the host forwards to the VM's SSH (22), so the installer can
# reach it with: ./install/install.sh vm --target nixos@localhost --ssh-port 2222
set -euo pipefail

ISO="${1:-}"
DISK="${2:-/tmp/nixos-vm.qcow2}"

OVMF_DIR="$(find /nix/store -maxdepth 1 -type d -name '*OVMF-*-fd' ! -name '*xen*' | head -1)"
if [[ -z $OVMF_DIR ]]; then
  echo "Error: OVMF firmware not found in the nix store." >&2
  echo "  Get it once: nix-shell -p OVMF --run true" >&2
  exit 1
fi

VARS="$(mktemp /tmp/OVMF_VARS.XXXXXX)"
cp "$OVMF_DIR/FV/OVMF_VARS.fd" "$VARS"

if [[ -z $ISO && ! -e $DISK ]]; then
  echo "Error: no ISO given and disk '$DISK' does not exist." >&2
  echo "  Pass a NixOS minimal ISO to run the installer (fresh install)." >&2
  echo "  Or point at a disk image that already has an installed system to boot it." >&2
  exit 1
fi

if [[ ! -e $DISK ]]; then
  echo "==> Creating 40G disk image: $DISK"
  qemu-img create -f qcow2 "$DISK" 40G
fi

# shellcheck disable=SC2054 # QEMU options keep commas inside a single argument
qemu_args=(
  -accel kvm -machine q35 -cpu host
  -smp 4 -m 6G
  -drive file="$DISK",if=virtio
  -netdev user,id=n0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=n0
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_DIR/FV/OVMF_CODE.fd"
  -drive if=pflash,format=raw,file="$VARS"
)

if [[ -n $ISO ]]; then
  # shellcheck disable=SC2054 # comma is part of the single -drive option
  qemu_args+=(-boot d -drive file="$ISO",media=cdrom,readonly=on)
else
  qemu_args+=(-boot c)
fi

exec qemu-system-x86_64 "${qemu_args[@]}"
