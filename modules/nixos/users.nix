{
  pkgs,
  user,
  ...
}:

{
  programs.zsh.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    initialPassword = "changeme";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
    ];
  };
}
