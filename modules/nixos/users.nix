{
  pkgs,
  user,
  ...
}:

{
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "123";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
    ];
  };
}
