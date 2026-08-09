{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      init.defaultBranch = "main";
      fetch.prune = true;
      push.autoSetupRemote = true;
      pull.rebase = false;
    };
  };
}
