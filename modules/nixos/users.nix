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
  };
}
