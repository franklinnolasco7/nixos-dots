{
  config,
  ...
}:
{
  # One agent per login, exported to every shell (zsh included) via
  # sshAuthSock; without it each terminal needs its own `eval "$(ssh-agent)"`.
  services.ssh-agent.enable = true;

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
