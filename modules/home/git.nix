{ ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Frank";
        email = "116436582+franklinnolasco7@users.noreply.github.com";
        signingkey = "/home/frank/.ssh/id_ed25519.pub";
      };
      core = {
        editor = "vim";
      };
      gpg = {
        format = "ssh";
        ssh.allowedSignersFile = "/home/frank/.config/git/allowed_signers";
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

  # SSH public key used for commit signature verification.
  # Replace public key below with key from ~/.ssh/id_ed25519.pub when setting up a new system.
  home.file.".config/git/allowed_signers".text =
    "116436582+franklinnolasco7@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtOXqQXYBzKOemkphICYNyUGXOBAMe2HH3bxszTd6R0";
}