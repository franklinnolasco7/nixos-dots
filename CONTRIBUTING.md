# Contributing

## Principle

**KISS — Keep It Simple.** No over-engineering, no gold-plating. If it adds
complexity, it needs a reason.

**YAGNI — You Aren't Gonna Need It.** Don't build for hypothetical futures;
add something only when you actually need it.

**DRY — Don't Repeat Yourself.** Prefer shared modules over copy-paste; a
change should land in one place.

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

Follow the [Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
specification, one line:

```text
<type>[optional scope]: <description>
```

```text
feat:        new module/feature
fix:         bug fix
docs:        documentation
style:       formatting, no behavior change
refactor:    code change, no behavior change
perf:        performance improvement
test:        tests
build:       build system / dependencies
ci:          CI configuration
chore:       maintenance, cleanup
revert:      revert a previous commit
```

Examples:

```text
feat(install): add hosts/vm rehearsal host + UEFI run-vm.sh
fix(install): make run-vm.sh find OVMF in the nix store
docs: document safe.directory prerequisite for sudo rebuilds
```

## Code of Conduct

[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)