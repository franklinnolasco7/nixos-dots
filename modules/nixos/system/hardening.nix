{ ... }:
{
  # Key-only sshd: no password or keyboard-interactive auth, no root login.
  # This is shared hardening policy; enabling the daemon stays host-specific
  # (hosts/aspire7/configuration.nix) and the firewall exposes only port 22
  # (system/firewall.nix).
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };
}
