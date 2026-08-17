{
  pkgs,
  user,
  ...
}:

let
  # One binding per trusted device; revoke by deleting the line.
  termiusMobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKS4CVjtEhcmbf9+G/cmI+9GFdoQR17BkmQ1gnpPbgw termius-mobile";
in
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

    # Declarative SSH access for remote clients; sshd is key-only
    # (see hardening.nix), so every client key must be listed here.
    openssh.authorizedKeys.keys = [
      termiusMobile
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtOXqQXYBzKOemkphICYNyUGXOBAMe2HH3bxszTd6R0 franklin.nolasco.dev@gmail.com"
    ];
  };
}
