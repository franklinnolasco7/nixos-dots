{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    completionInit = ''
      autoload -U compinit
      compinit -C
    '';

    initContent = builtins.readFile ../../home/.zshrc;
  };
}
