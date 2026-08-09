{
  pkgs,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # User
  # ---------------------------------------------------------------------------

  users.users.frank = {
    isNormalUser = true;
    initialPassword = "changeme";

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
      micro
      swaybg
      fastfetch
      btop
      vscodium
      chromium
    ];
  };
}
