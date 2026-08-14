{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    # CachyOS-parity driver (matches the CachyOS kernel build) — see nyx.chaotic.cx.
    package =
      let
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
      in
      pkgs.nvidia_cachyos.overrideAttrs (o: {
        passthru = o.passthru // {
          mod = filePrefixMap o.passthru.mod;
        };
      });
  };
}
