{ config, lib, ... }:

let
  colors = (config.lib.stylix or { }).colors.withHashtag or { };
in
{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch = {
      enable = true;
      searchUpKey = "^[[A";
      searchDownKey = "^[[B";
    };

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      ls = "ls --color=auto";
      ".." = "cd ..";
    };

    sessionVariables = {
      BASH_MAX_OUTPUT_LENGTH = "15000";
    }
    // lib.optionalAttrs (config.myProfile == "full" && colors != { }) {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=${colors.base04}";
    };

    completionInit = ''
      autoload -U compinit
      compinit -C
    '';
  };
}
