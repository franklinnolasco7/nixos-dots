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

    # Second decryption identity: the user age key (user-frank). Lets sops
    # keep decrypting even if the host key is lost/regenerated, as long as
    # ~/.config/sops/age/keys.txt is restored after a reinstall.
    # pathExists is evaluated on the build machine: on the minimal ISO the
    # file is absent, so a first install only relies on the restored host key.
    sops.age.keyFile = lib.mkIf (builtins.pathExists /home/frank/.config/sops/age/keys.txt) "/home/frank/.config/sops/age/keys.txt";

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
