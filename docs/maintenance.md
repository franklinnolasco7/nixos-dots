# Maintenance

## Rebuild

```bash
./install/rebuild.sh            # switch (default, host = aspire7)
./install/rebuild.sh boot       # next boot only
./install/rebuild.sh test       # this boot only, reboot reverts
./install/rebuild.sh <host>     # switch another host
./install/rebuild.sh <host> boot
```

`rebuild.sh` runs `nixos-rebuild` via `sudo`, and the nix flake fetcher (libgit2)
refuses git repos not owned by root. Fix once per machine (repo owned by your
user, rebuilt as root):

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

## Before Rebuilding

```bash
nix flake check
sudo nixos-rebuild dry-activate --flake .#<host>
nixos-rebuild build --flake .#<host>
./install/format.sh check
```

All pass → `./install/rebuild.sh`.

Broken system: [troubleshooting.md](troubleshooting.md).