{ lib, ... }:

{
  imports = [
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
    EDITOR = "code-oss";
    VISUAL = "code-oss";
  };

  programs.home-manager.enable = true;
}
