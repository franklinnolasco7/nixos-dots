{
  lib,
  user,
  ...
}:

let
  secretsFile = ../../secrets/secrets.yaml;
  hasSecrets = builtins.pathExists secretsFile;
  homeDir = "/home/${user}";
in
{
  config = lib.mkIf hasSecrets {
    sops.defaultSopsFile = secretsFile;

    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    # Second decryption identity: the user age key. Lets sops keep decrypting
    # even if the host key is lost/regenerated, as long as
    # ~/.config/sops/age/keys.txt is restored after a reinstall.
    # pathExists is evaluated on the build machine: on the minimal ISO the
    # file is absent, so a first install only relies on the restored host key.
    sops.age.keyFile = lib.mkIf (builtins.pathExists "${homeDir}/.config/sops/age/keys.txt") "${homeDir}/.config/sops/age/keys.txt";

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
  };
}
