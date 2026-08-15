{
  pkgs,
  user,
  ...
}:

{
  # NixOS's generated /etc/zshrc runs an uncached compinit that re-validates
  # every completion on each interactive shell (~100ms per terminal open).
  # home-manager already runs a cached compinit -C, so the global one is pure
  # overhead.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
  };

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
