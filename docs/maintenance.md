# Maintenance

## Rebuild

```bash
./install/rebuild.sh            # switch (default, host = aspire7)
./install/rebuild.sh boot       # next boot only
./install/rebuild.sh test       # this boot only, reboot reverts
./install/rebuild.sh <host>     # switch another host
./install/rebuild.sh <host> boot
./install/rebuild.sh <host>-min # switch the console-TTY profile variant
```

`rebuild.sh` runs `nixos-rebuild` via `sudo`, and the nix flake fetcher (libgit2)
refuses git repos not owned by root. The installer already writes
`safe.directory` for root on every fresh install, so new systems are covered.

Only an existing multi-user system that never ran the installer needs it once
(repo owned by your user, rebuilt as root):

```bash
sudo git config --global --add safe.directory "$(pwd)"
```

A fresh install's ISO runs everything as root, so it only needs this on an
existing multi-user system.

## Update

```bash
./install/update.sh             # flake inputs + rebuild
```

## Format

```bash
./install/format.sh             # write (default)
./install/format.sh check       # verify only
```

Nix, Lua, shell, TOML. Needs `nix develop`.

## Tweaks

Every performance/reliability tweak, why it exists, and how to verify:
[tweaks.md](tweaks.md).

## Before Rebuilding

```bash
nix flake check
sudo nixos-rebuild dry-activate --flake .#<host>
nixos-rebuild build --flake .#<host>
./install/format.sh check
```

All pass → `./install/rebuild.sh`.

Broken system: [troubleshooting.md](troubleshooting.md).

## WireGuard VPN (manual)

The Proton profile stays out of the flake; `wg0.conf` is personal.

1. Get `wg0.conf` from Proton (VPN → WireGuard configuration → generate keys).
2. Install it:
   ```bash
   sudo mkdir -p /etc/wireguard
   sudo cp wg0.conf /etc/wireguard/wg0.conf
   sudo chmod 600 /etc/wireguard/wg0.conf
   ```
   > [!IMPORTANT]
   > `DNS = <proton-dns>` is **required** in `wg0.conf` (e.g. `10.2.0.2` for
   > Proton). wg-quick pushes DNS through the resolver only when the `DNS`
   > key is present; without it the tunnel comes up but resolution leaks to
   > the clearnet.
3. Toggle with `vpn-toggle` (toggle button in the swaync control center,
   `modules/home/wayland/swaync/default.nix`):
   ```bash
   vpn-toggle            # toggle connect/disconnect
   vpn-toggle status     # prints true/false (feeds the swaync toggle state)
   ```

DNS goes through systemd-resolved (`services.resolved.enable` +
`networking.networkmanager.dns = "systemd-resolved"`); `vpn-toggle` clears a
stale `/run/resolvconf/lock` before each `wg-quick` run so the DNS hook can't
hang.