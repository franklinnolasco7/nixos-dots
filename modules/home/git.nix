{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Frank";
    userEmail = "REDACTED";

    settings = {
      init.defaultBranch = "main";
      fetch.prune = true;
      push.autoSetupRemote = true;
      pull.rebase = false;
    };
  };
}
