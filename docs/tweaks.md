# Tweaks

Every performance/reliability tweak in one place, for future reference when
something misbehaves. Source: Zen kernel + settings
([wiki.archlinux.org/title/Linux-zen](https://wiki.archlinux.org/title/Linux-zen), [cache.nixos.org](https://cache.nixos.org/)).

## Kernel

| What | Where | Effect |
|---|---|---|
| `linuxPackages_zen` | `hosts/aspire7/configuration.nix` | EEVDF, sched-ext, ntsync built in; cached on cache.nixos.org |

## sysctl: `modules/nixos/system/tuning.nix`

| Key | Value | Why |
|---|---|---|
| `vm.swappiness` | 180 | zram companion: swap early, compress instead of evicting page cache |
| `net.ipv4.tcp_congestion_control` | `bbr` | BBR (module `tcp_bbr` in `boot.kernelModules`) |
| `vm.page-cluster` | 0 | no swap readahead with zram |
| `kernel.nmi_watchdog` | 0 | drops per-core NMI overhead; loses NMI lockup detection |
| `net.core.netdev_max_backlog` | 65536 | network receive backlog headroom |

- `boot.blacklistedKernelModules = ["iTCO_wdt" "sp5100_tco"]`; watchdog timers
  unused (`nmi_watchdog=0`), so never load them.

## systemd / journald: `modules/nixos/system/tuning.nix`

- `systemd.settings.Manager`: `DefaultTimeoutStartSec=15s`,
  `DefaultTimeoutStopSec=10s` (fast boot-failure fallback),
  `DefaultLimitNOFILE=1048576` (FD headroom).
- `services.journald.extraConfig = "SystemMaxUse=50M"`; log cap.

## Services: `modules/nixos/system/tuning.nix`

| Service | Detail |
|---|---|
| `services.scx` | `scx_rustland` scheduler (requires kernel ≥ 6.12) |
| `services.fstrim` | weekly NVMe TRIM |

- udev rule grants `wheel` write access to `scaling_governor` (sysfs).
- Scoped passwordless sudo for `sysctl -w vm.swappiness=*` (waybar consumer).

## zram: `modules/nixos/system/boot.nix`

`zramSwap` with `zstd` (swap on compressed RAM). This is the only swap; the
disk swap partition was dropped when root went LUKS (see `modules/disko/gpt-layout.nix`).

## Audio: `modules/nixos/system/audio.nix`

CachyOS `20-audio-pm.rules` port: `snd-hda-intel` `power_save` forced to `0`
on AC (prevents audio cracks), restored to the saved value (default 10) on
battery. Saved value kept in `/run/udev/snd-hda-intel-powersave`.

## NVIDIA: `modules/nixos/tools/nvidia.nix`

- `modesetting` + `powerManagement` enabled.
- `powerManagement.finegrained` adds `NVreg_DynamicPowerManagement=0x02` +
  runtime-PM bind/unbind udev rules (mobile dGPU powers down when idle; needs
  offload mode).
- `boot.extraModprobeConfig`: `NVreg_InitializeSystemMemoryAllocations=0`
  (skip clearing GPU allocations) + `NVreg_EnableS0ixPowerManagement=1`.

## Verify after a rebuild

```bash
sysctl net.ipv4.tcp_congestion_control   # bbr
cat /proc/sys/vm/page-cluster             # 0
cat /sys/module/snd_hda_intel/parameters/power_save  # 0 on AC, 10 on battery
systemctl status scx_rustland fstrim.timer
```

## Deliberately not applied

- CPU microarch override; no cache for it → costly local kernel build.
- `linuxPackages_zen-hardened` / `-bmq`; no sched-ext.
