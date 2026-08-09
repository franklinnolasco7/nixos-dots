{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    initContent = builtins.readFile ../../home/.zshrc;
  };

  programs.starship = {
    enable = true;
  };
}
