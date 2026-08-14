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
  programs.gamescope.enable = true;

  # Protontricks drives Steam's own Proton prefixes; no system wine needed.
  environment.systemPackages = with pkgs; [
    protontricks
  ];
}
