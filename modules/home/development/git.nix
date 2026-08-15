{
  config,
  ...
}:
{
  programs.git = {
    enable = true;
    settings = {
      core = {
        editor = "micro";
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      };
      commit = {
        gpgsign = true;
      };
      init.defaultBranch = "main";
      fetch.prune = true;
      push.autoSetupRemote = true;
      pull.rebase = false;
    };
  };
}
