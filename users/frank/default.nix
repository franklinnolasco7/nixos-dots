{
  config,
  lib,
  inputs,
  pkgs,
  user,
  profile,
  ...
}:

{
  imports = [
    ../../modules/home
  ]
  ++ lib.optionals (profile == "full") [
    inputs.hyprland.homeManagerModules.default
  ];

  home.username = user;
  home.homeDirectory = lib.mkForce "/home/${user}";

  # Git identity (shared modules/home/development/git.nix keeps the generic settings).
  programs.git.settings.user = {
    name = "Frank";
    email = "116436582+franklinnolasco7@users.noreply.github.com";
    signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  };

  # SSH public key used for commit signature verification.
  home.file.".config/git/allowed_signers".text =
    "116436582+franklinnolasco7@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtOXqQXYBzKOemkphICYNyUGXOBAMe2HH3bxszTd6R0";
  home.stateVersion = "26.05";

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
  ];

  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  home.activation.createSshKey = lib.mkAfter ''
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -N "" -C "${user}@local" -f "$HOME/.ssh/id_ed25519"
    fi
  '';

  programs.home-manager.enable = true;
}
