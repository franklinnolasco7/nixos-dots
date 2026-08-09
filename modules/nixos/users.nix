{ pkgs, ... }:

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
      git
      kitty
      neovim
      rofi
      thunar
      waybar
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
