{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Frank";
        email = "116436582+franklinnolasco7@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      fetch.prune = true;
      push.autoSetupRemote = true;
      pull.rebase = false;
    };
  };
}