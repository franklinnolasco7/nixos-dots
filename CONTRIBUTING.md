# Contributing

## Setup

```bash
nix develop
```

## Format

```bash
./install/format.sh check   # verify
./install/format.sh         # write
```

## Validate

```bash
nix flake check
nixos-rebuild build --flake .#<host>
```

See [maintenance.md](docs/maintenance.md) for the full workflow.

## Commits

Conventional Commits, one line:

```text
feat:      new module/feature
fix:       bug fix
docs:      documentation
chore:     maintenance, deps, cleanup
refactor:  code change, no behavior change
```

## Code of Conduct

[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)