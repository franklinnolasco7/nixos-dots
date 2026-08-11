# Maintenance

Daily operations. Requires `nix` — use `nix develop` for the dev shell if a command is missing.

## Rebuild

```bash
./install/rebuild.sh            # switch (default)
./install/rebuild.sh boot       # activate on next boot only
./install/rebuild.sh test       # activate for this boot, reboot reverts
```

## Update

```bash
./install/update.sh             # flake inputs update + rebuild
```

## Format

```bash
./install/format.sh             # write (default)
./install/format.sh check       # verify only
```

Formats Nix, Lua, shell, and TOML files.

## Before Rebuilding

Validate first, then switch:

```bash
nix flake check                                  # full evaluation (NixOS + disko)
sudo nixos-rebuild dry-activate --flake .#<host> # show changes, apply nothing
nixos-rebuild build --flake .#<host>             # build without touching system
./install/format.sh check
```

Only when all pass: `./install/rebuild.sh`.

If a rebuild breaks something: [troubleshooting.md](troubleshooting.md).