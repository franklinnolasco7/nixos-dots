{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ../../modules/home
  ];

  home.username = "frank";
  home.homeDirectory = lib.mkForce "/home/frank";

  # Git identity (shared modules/home/git.nix keeps the generic settings).
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
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.opencode/bin"
    "$HOME/.spicetify"
  ];

  home.sessionVariables = {
    EDITOR = "micro";
    VISUAL = "micro";
  };

  programs.home-manager.enable = true;
}
