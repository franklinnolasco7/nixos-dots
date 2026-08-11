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
      gpg = {
        format = "ssh";
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

  home.file.".config/git/allowed_signers".text =
    "116436582+franklinnolasco7@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHtOXqQXYBzKOemkphICYNyUGXOBAMe2HH3bxszTd6R0";
}