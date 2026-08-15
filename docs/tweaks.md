# Tweaks

Every performance/reliability tweak in one place, for future reference when
something misbehaves. Source: CachyOS kernel + settings
([wiki.cachyos.org](https://wiki.cachyos.org/), [nyx.chaotic.cx](https://www.nyx.chaotic.cx/)).

## Kernel

| What | Where | Effect |
|---|---|---|
| `linuxPackages_cachyos` | `hosts/aspire7/configuration.nix` | EEVDF/BORE scheduler, sched-ext, BBR3, ntsync built in; cached on nyx |

## sysctl — `modules/nixos/system/tuning.nix`

| Key | Value | Why |
|---|---|---|
| `vm.swappiness` | 180 | zram companion: swap early, compress instead of evicting page cache |
| `net.ipv4.tcp_congestion_control` | `bbr3` | BBRv3 (module `tcp_bbr3` in `boot.kernelModules`) |
| `vm.page-cluster` | 0 | no swap readahead with zram |
| `kernel.nmi_watchdog` | 0 | drops per-core NMI overhead; loses NMI lockup detection |
| `net.core.netdev_max_backlog` | 65536 | network receive backlog headroom |

- `boot.blacklistedKernelModules = ["iTCO_wdt" "sp5100_tco"]` — watchdog timers
  unused (`nmi_watchdog=0`), so never load them.

## systemd / journald — `modules/nixos/system/tuning.nix`

- `systemd.settings.Manager`: `DefaultTimeoutStartSec=15s`,
  `DefaultTimeoutStopSec=10s` (fast boot-failure fallback),
  `DefaultLimitNOFILE=1048576` (FD headroom).
- `services.journald.extraConfig = "SystemMaxUse=50M"` — log cap.

## Services — `modules/nixos/system/tuning.nix`

| Service | Detail |
|---|---|
| `services.scx` | `scx_rustland` scheduler (requires kernel ≥ 6.12) |
| `services.fstrim` | weekly NVMe TRIM |

- udev rule grants `wheel` write access to `scaling_governor` (sysfs).
- Scoped passwordless sudo for `sysctl -w vm.swappiness=*` (waybar consumer).

## zram — `modules/nixos/system/boot.nix`

`zramSwap` with `zstd` (swap on compressed RAM). This is the only swap — the
disk swap partition was dropped when root went LUKS (see `modules/disko/gpt-layout.nix`).

## Audio — `modules/nixos/system/audio.nix`

CachyOS `20-audio-pm.rules` port: `snd-hda-intel` `power_save` forced to `0`
on AC (prevents audio cracks), restored to the saved value (default 10) on
battery. Saved value kept in `/run/udev/snd-hda-intel-powersave`.

## NVIDIA — `modules/nixos/tools/nvidia.nix`

- `nvidia_cachyos` driver (CachyOS parity build), `modesetting` +
  `powerManagement` enabled.
- `powerManagement.finegrained` adds `NVreg_DynamicPowerManagement=0x02` +
  runtime-PM bind/unbind udev rules (mobile dGPU powers down when idle; needs
  offload mode).
- `boot.extraModprobeConfig`: `NVreg_InitializeSystemMemoryAllocations=0`
  (skip clearing GPU allocations) + `NVreg_EnableS0ixPowerManagement=1`.
- `-ffile-prefix-map` override remaps the kernel `-dev` tree so the module
  output stays self-contained (see comment in file for the `allowedReferences`
  failure it fixes).

## Verify after a rebuild

```bash
sysctl net.ipv4.tcp_congestion_control   # bbr3
cat /proc/sys/vm/page-cluster             # 0
cat /sys/module/snd_hda_intel/parameters/power_save  # 0 on AC, 10 on battery
systemctl status scx_rustland fstrim.timer
```

## Deliberately not applied

- `chaotic.mesa-git` — breaks NVIDIA libgbm on PRIME; stock mesa stays.
- `chaotic.hdr` — AMD-only.
- CPU microarch override — no nyx cache for it → costly local kernel build.
- `linuxPackages_cachyos-hardened` / `-bmq` — no sched-ext.
