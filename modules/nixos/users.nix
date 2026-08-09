{ pkgs, inputs, ... }:

{
  programs.zsh.enable = true;

  users.users.frank = {
    isNormalUser = true;
    initialPassword = "changeme";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      tree
      kitty
      neovim
      rofi
      thunar
      # TEMP WORKAROUND: waybar-git build (Hyprland Lua dispatch fix).
      # Switch back to pkgs.waybar when nixpkgs ships the fix.
      inputs.waybar.packages.${pkgs.system}.default
      libnotify
      swaynotificationcenter
      micro
      fastfetch
      btop
      vscodium
      chromium
    ];
  };
}
