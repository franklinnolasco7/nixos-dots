{ pkgs, ... }:

{
  home.packages = [
    (pkgs.heroic.override {
      # gamescope/gamemode must live inside Heroic's FHS wrapper for games to
      # use them (both already enabled system-wide in modules/nixos/tools/gaming.nix).
      extraPkgs =
        pkgs': with pkgs'; [
          gamescope
          gamemode
        ];
    })
  ];

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
  };

  # Run Steam and Heroic on the NVIDIA dGPU via PRIME offload. Games inherit the
  # offload env from the launcher they spawn, so every game uses the dGPU while
  # the launcher UI itself does too. The dGPU powers back down (finegrained
  # runtime PM) once the launcher is closed. nvidia-offload comes from
  # hardware.nvidia.prime.offload.enableOffloadCmd (modules/nixos/tools/nvidia.nix).
  xdg.desktopEntries = {
    steam = {
      name = "Steam";
      exec = "nvidia-offload steam %U";
      icon = "steam";
      categories = [
        "Network"
        "FileTransfer"
        "Game"
      ];
      mimeType = [
        "x-scheme-handler/steam"
        "x-scheme-handler/steamlink"
      ];
      terminal = false;
      type = "Application";
    };

    "com.heroicgameslauncher.hgl" = {
      name = "Heroic Games Launcher";
      exec = "nvidia-offload heroic %u";
      icon = "com.heroicgameslauncher.hgl";
      comment = "An Open Source Launcher for GOG, Epic Games and Amazon Games";
      categories = [ "Game" ];
      mimeType = [ "x-scheme-handler/heroic" ];
      terminal = false;
      type = "Application";
      settings."StartupWMClass" = "heroic";
    };
  };
}
