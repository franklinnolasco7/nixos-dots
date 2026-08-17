{
  user,
  ...
}:

let
  secretsFile = ../../../secrets/secrets.yaml;
  homeDir = "/home/${user}";
in
{
  config = {
    sops.defaultSopsFile = secretsFile;

    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    # sops-install-secrets runs as root and creates parent dirs of its secret
    # targets, which breaks home-manager linking into user-owned dirs (e.g.
    # ~/.config/opencode/opencode.json). Create them user-owned first.
    systemd.tmpfiles.rules = [
      "d ${homeDir}/.config/opencode 0755 ${user} users -"
      "d ${homeDir}/.config/github 0755 ${user} users -"
    ];

    sops.secrets.context7-api-key = {
      path = "${homeDir}/.config/opencode/context7-key";
      owner = user;
      group = "users";
      mode = "0400";
    };

    sops.secrets.github-token = {
      path = "${homeDir}/.config/opencode/github-token";
      owner = user;
      group = "users";
      mode = "0400";
    };

    sops.secrets.github-project-token = {
      path = "${homeDir}/.config/github/projects-token";
      owner = user;
      group = "users";
      mode = "0400";
    };

    # frank's password hash (declarative). Applied on every activation, so a
    # password change is "update the hash in secrets.yaml + rebuild"; no
    # plaintext anywhere. neededForUsers so it decrypts before the user is
    # created on a fresh install.
    sops.secrets.user-password-hash = {
      neededForUsers = true;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
