{
  config,
  pkgs,
  ...
}:
{
  services.ssh-agent.enable = true;

  systemd.user.services.ssh-add = {
    Unit = {
      Description = "Load SSH keys into agent";
      After = [ "ssh-agent.service" ];
      Requires = [ "ssh-agent.service" ];
    };
    Service = {
      Type = "oneshot";
      Restart = "on-failure";
      RestartSec = 2;
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
      ExecStart = "${pkgs.openssh}/bin/ssh-add ${config.home.homeDirectory}/.ssh/id_ed25519";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
