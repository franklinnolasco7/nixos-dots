{
  pkgs,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
  ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    # Runtime PM on driver bind/unbind (NVreg_DynamicPowerManagement=0x02):
    # lets the mobile dGPU power down when idle. Requires offload mode.
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    # nixpkgs' newest stable driver (currently 610.x), built against the zen
    # kernel; served from cache.nixos.org.
    branch = "latest";
  };

  # dGPU defaults: InitializeSystemMemoryAllocations=0 skips clearing GPU
  # allocations (small VRAM/encode win), EnableS0ixPowerManagement lets the idle
  # mobile GPU suspend to S0ix. Keys don't collide with the ones nixpkgs
  # generates for the nvidia module (PreserveVideoMemoryAllocations...).
  boot.extraModprobeConfig = "options nvidia NVreg_InitializeSystemMemoryAllocations=0 NVreg_EnableS0ixPowerManagement=1";
}
