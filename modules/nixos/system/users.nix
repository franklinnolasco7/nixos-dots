{
  pkgs,
  user,
  ...
}:

{
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
    ];
  };
}
