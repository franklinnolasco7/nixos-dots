{ ... }:

{
  programs.zsh = {
    enable = true;

    initContent = builtins.readFile ../../home/.zshrc;
  };
}
