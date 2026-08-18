{
  pkgs,
  user,
  ...
}:

let
  homeDir = "/home/${user}";
  # One binding per trusted device; revoke by deleting the line.
  termiusMobile = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHKS4CVjtEhcmbf9+G/cmI+9GFdoQR17BkmQ1gnpPbgw termius-mobile";
in
{
  # Keep passwords managed by `passwd`; rebuilds must preserve /etc/shadow.
  users.mutableUsers = true;

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

  # A mistaken `sudo mkdir -p ~/.config/...` can leave any missing component
  # root-owned. Repair this user-owned tree before every Home Manager service
  # start so dconf cannot abort activation and hide downstream configs.
  systemd.services."home-config-ownership-${user}" = {
    description = "Restore ownership of ${user}'s configuration directory";
    before = [ "home-manager-${user}.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.coreutils}/bin/install -d -m 0755 -o ${user} -g users ${homeDir}/.config
      ${pkgs.findutils}/bin/find ${homeDir}/.config -xdev \
        \( ! -user ${user} -o ! -group users \) \
        -exec ${pkgs.coreutils}/bin/chown --no-dereference ${user}:users {} +
    '';
  };

  systemd.services."home-manager-${user}" = {
    requires = [ "home-config-ownership-${user}.service" ];
    after = [ "home-config-ownership-${user}.service" ];
  };
}
