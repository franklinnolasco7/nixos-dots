{ lib, ... }:

let
  secretsFile = ../../secrets/secrets.yaml;
  hasSecrets = builtins.pathExists secretsFile;
in
{
  config = lib.mkIf hasSecrets {
    sops.defaultSopsFile = secretsFile;

    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
    ];

    sops.secrets.context7-api-key = {
      path = "/home/frank/.config/opencode/context7-key";
      owner = "frank";
      group = "users";
      mode = "0400";
    };

    sops.secrets.github-token = {
      path = "/home/frank/.config/opencode/github-token";
      owner = "frank";
      group = "users";
      mode = "0400";
    };
  };
}
