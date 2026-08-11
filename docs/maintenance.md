# Maintenance

## Rebuild

```bash
./install/rebuild.sh            # switch (default)
./install/rebuild.sh boot       # next boot only
./install/rebuild.sh test       # this boot only, reboot reverts
```

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