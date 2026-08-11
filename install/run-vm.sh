#!/usr/bin/env bash
# Boot the NixOS minimal ISO in QEMU/KVM with UEFI (OVMF) for installer
# rehearsal. Targets the `vm` flake host (hosts/vm, install/install.sh vm).
#
# Usage:
#   ./install/run-vm.sh /path/to/nixos-minimal.iso [disk-image]
#
# Disk defaults to /tmp/nixos-vm.qcow2 (40G sparse, created if missing).
# The installed system is expected on /dev/vda (see hosts/vm/disko.nix).
set -euo pipefail

ISO="${1:-}"
DISK="${2:-/tmp/nixos-vm.qcow2}"

if [[ -z $ISO ]]; then
  echo "Error: pass the NixOS minimal ISO path." >&2
  echo "Usage: $0 <minimal-iso> [disk-image]" >&2
  exit 1
fi

OVMF_DIR="$(find /nix/store -maxdepth 1 -type d -name '*OVMF-*-fd' ! -name '*xen*' | head -1)"
if [[ -z $OVMF_DIR ]]; then
  echo "Error: OVMF firmware not found in the nix store." >&2
  echo "  Get it once: nix-shell -p OVMF --run true" >&2
  exit 1
fi

VARS="$(mktemp /tmp/OVMF_VARS.XXXXXX)"
cp "$OVMF_DIR/FV/OVMF_VARS.fd" "$VARS"

if [[ ! -e $DISK ]]; then
  echo "==> Creating 40G disk image: $DISK"
  qemu-img create -f qcow2 "$DISK" 40G
fi

exec qemu-system-x86_64 -accel kvm -machine q35 -cpu host \
  -smp 4 -m 6G -boot d \
  -drive file="$ISO",media=cdrom,readonly=on \
  -drive file="$DISK",if=virtio \
  -netdev user,id=n0 -device virtio-net-pci,netdev=n0 \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_DIR/FV/OVMF_CODE.fd" \
  -drive if=pflash,format=raw,file="$VARS"
