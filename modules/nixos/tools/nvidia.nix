{
  config,
  inputs,
  pkgs,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    # Runtime PM on driver bind/unbind (NVreg_DynamicPowerManagement=0x02):
    # lets the mobile dGPU power down when idle. Requires offload mode.
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package =
      let
        # Isolated pkg set: the nvidia-patch overlay adds patch-fbc / patch-nvenc
        # / nvidia-patch-list without touching the shared pkgs.
        pkgs-nvidia = pkgs.appendOverlays [ inputs.nvidia-patch.overlays.default ];

        # The nvidia kernel modules embed paths pointing into the kernel -dev
        # tree (nvidia-uvm's __FILE__ assert strings plus DWARF debug paths),
        # which trips the `allowedReferences = [ ]` check on
        # nvidia-kernel-modules. Remap the dev tree to a relative path so the
        # module output stays self-contained.
        filePrefixMap =
          drv:
          drv.overrideAttrs (attrs: {
            makeFlags = attrs.makeFlags ++ [
              "KCFLAGS+=-ffile-prefix-map=${config.boot.kernelPackages.kernel.dev}="
            ];
          });

        # CachyOS-parity driver (matches the CachyOS kernel build); see
        # nyx.chaotic.cx. The keylase patch list may lag a driver version; the
        # hasAttr guards below skip the patch instead of breaking the build.
        targetPkg = pkgs.nvidia_cachyos;

        # Unlock the NVENC session limit + FBC (keylase patches) on the consumer
        # GPU for OBS NVENC. Guard skips a patch while a driver version isn't in
        # the upstream patch list yet, instead of breaking the build.
        pkgAfterFbc =
          if builtins.hasAttr targetPkg.version pkgs-nvidia.nvidia-patch-list.fbc then
            pkgs-nvidia.nvidia-patch.patch-fbc targetPkg
          else
            targetPkg;

        pkgAfterNvenc =
          if builtins.hasAttr targetPkg.version pkgs-nvidia.nvidia-patch-list.nvenc then
            pkgs-nvidia.nvidia-patch.patch-nvenc pkgAfterFbc
          else
            pkgAfterFbc;
      in
      pkgAfterNvenc.overrideAttrs (o: {
        passthru = o.passthru // {
          mod = filePrefixMap o.passthru.mod;
        };
      });
  };

  # CachyOS defaults for the dGPU: InitializeSystemMemoryAllocations=0 skips
  # clearing GPU allocations (small VRAM/encode win), EnableS0ixPowerManagement
  # lets the idle mobile GPU suspend to S0ix. Keys don't collide with the ones
  # nixpkgs generates for the nvidia module (PreserveVideoMemoryAllocations...).
  boot.extraModprobeConfig = "options nvidia NVreg_InitializeSystemMemoryAllocations=0 NVreg_EnableS0ixPowerManagement=1";
}
