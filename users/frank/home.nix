{ lib, inputs, ... }:

{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ../../modules/home
  ];

  home.username = "frank";
  home.homeDirectory = lib.mkForce "/home/frank";

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
