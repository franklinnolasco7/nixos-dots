{ pkgs, ... }:

{
  # 32-bit Mesa/glibc drivers — required for 32-bit games and their DXVK/Vulkan
  # stacks (see wiki.nixos.org/wiki/Steam "Steam fails to start").
  hardware.graphics.enable32Bit = true;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  # Proton-GE ships a steamcompattool output; it shows up as "GE-Proton" under
  # Steam → Settings → Compatibility (wiki.nixos.org/wiki/Steam "Proton").
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # MangoHud must live inside Steam's FHS env so games can dlopen its overlay;
  # toggling happens via MANGOHUD=1 (set session-wide in modules/home/programs/gaming.nix).
  programs.steam.extraPackages = [ pkgs.mangohud ];

  programs.gamemode.enable = true;

  programs.gamescope = {
    enable = true;
    # cap_sys_nice wrapper so gamescope can renice child processes (pairs with
    # gamemode scheduling under gamescopeSession).
    capSysNice = true;
  };

  # The zen kernel builds NTSYNC (CONFIG_NTSYNC=y) but nixpkgs ships no udev
  # rule for it, leaving /dev/ntsync root-only; Proton then silently falls back
  # to esync. Grant uaccess so user-run games can open it.
  services.udev.extraRules = ''
    KERNEL=="ntsync", MODE="0660", TAG+="uaccess"
  '';

  # CachyOS low-latency audio: cap the DSP quantum so audio glitch headroom
  # stays tight under game load.
  services.pipewire.extraConfig.pipewire."92-low-latency"."context.properties" = {
    "default.clock.rate" = 48000;
    "default.clock.quantum" = 512;
    "default.clock.min-quantum" = 256;
    "default.clock.max-quantum" = 1024;
  };

  # Reset PCI latency timers (from CachyOS-Settings pci-latency); sleep resets
  # the values, so pci-latency-on-resume re-applies them after wake.
  systemd.services.pci-latency = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.pciutils ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
    };
    script = ''
      setpci -v -s '*:*' latency_timer=20
      setpci -v -s '0:0' latency_timer=0
      setpci -v -d "*:*:04xx" latency_timer=80
    '';
  };

  systemd.services.pci-latency-on-resume = {
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    serviceConfig = {
      User = "root";
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
    unitConfig.StopWhenNeeded = "yes";
    path = [
      pkgs.coreutils
      pkgs.systemd
    ];
    script = "exit 0";
    postStop = ''
      systemctl restart pci-latency
    '';
  };

  # Auto-nice daemon with CachyOS's gaming-tuned rules; pairs with the
  # scx_rustland scheduler (modules/nixos/system/tuning.nix).
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # Protontricks drives Steam's own Proton prefixes; no system wine needed.
  environment.systemPackages = with pkgs; [
    protontricks
  ];
}
