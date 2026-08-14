# Tweaks

Every performance/reliability tweak in one place, for future reference when
something misbehaves. Kernel is `linux_zen`; some ideas trace back to CachyOS
settings ([wiki.cachyos.org](https://wiki.cachyos.org/)).

## Kernel

| What | Where | Effect |
|---|---|---|
| `linuxKernel.packages.linux_zen` | `hosts/aspire7/configuration.nix` | interactive desktop/gaming tuning: preempt, FQ-CoDel, sched-ext, ntsync |

## sysctl — `modules/nixos/system/tuning.nix`

| Key | Value | Why |
|---|---|---|
| `vm.swappiness` | 180 | zram companion: swap early, compress instead of evicting page cache |
| `vm.page-cluster` | 0 | no swap readahead with zram |
| `kernel.nmi_watchdog` | 0 | drops per-core NMI overhead; loses NMI lockup detection |
| `net.core.netdev_max_backlog` | 65536 | network receive backlog headroom |

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

- `nvidiaPackages.stable` driver, `modesetting` + `powerManagement` enabled.
- `-ffile-prefix-map` override remaps the kernel `-dev` tree so the module
  output stays self-contained (see comment in file for the `allowedReferences`
  failure it fixes).

## Verify after a rebuild

```bash
cat /proc/sys/vm/page-cluster             # 0
cat /sys/module/snd_hda_intel/parameters/power_save  # 0 on AC, 10 on battery
systemctl status scx_rustland fstrim.timer
```

## Deliberately not applied

- `chaotic.mesa-git` — breaks NVIDIA libgbm on PRIME; stock mesa stays.
- `chaotic.hdr` — AMD-only.
- CPU microarch override — no nyx cache for it → costly local kernel build.
- `linuxPackages_cachyos-hardened` / `-bmq` — no sched-ext.
- ntsync — module absent from the installed kernel tree.
