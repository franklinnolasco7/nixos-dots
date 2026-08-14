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

        # `latest` (not `stable`): keylase's patch list only covers drivers up
        # to the current branch, and `stable` has lagged behind it.
        targetPkg = config.boot.kernelPackages.nvidiaPackages.latest;

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
}
