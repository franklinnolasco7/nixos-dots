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

    # Dedicated age key, decoupled from the SSH host key: rotating the host
    # key never affects secret decryption. Provisioned by install.sh and
    # key-backup.sh; generateKey only bootstraps a fresh host with no key
    # staged - that generated identity is not an authorized recipient of
    # existing committed secrets (see docs/secrets.md).
    sops.age.keyFile = "/etc/sops-nix/keys.txt";
    sops.age.generateKey = true;

    # Root-run setup (including sops-install-secrets) must not create missing
    # parents in the user's home: `mkdir -p` would make them root-owned and
    # block Home Manager before it can create the Hyprland config. Declare the
    # complete directory chain, including dconf's writable database directory.
    # tmpfiles also repairs the ownership/mode of these directories if they
    # already exist with the wrong owner.
    systemd.tmpfiles.rules = [
      "d ${homeDir}/.config 0755 ${user} users -"
      "d ${homeDir}/.config/dconf 0700 ${user} users -"
      "d ${homeDir}/.config/opencode 0755 ${user} users -"
      "d ${homeDir}/.config/github 0755 ${user} users -"
      "d ${homeDir}/.config/restic 0700 ${user} users -"
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

    # restic (modules/home/programs/restic): one file per credential so the
    # backup script can read each value directly.
    sops.secrets.b2-key-id = {
      path = "${homeDir}/.config/restic/b2-key-id";
      owner = user;
      group = "users";
      mode = "0400";
    };

    sops.secrets.b2-application-key = {
      path = "${homeDir}/.config/restic/b2-application-key";
      owner = user;
      group = "users";
      mode = "0400";
    };

    sops.secrets.restic-password = {
      path = "${homeDir}/.config/restic/restic-password";
      owner = user;
      group = "users";
      mode = "0400";
    };

  };
}
