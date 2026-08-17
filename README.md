<div align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://github.com/user-attachments/assets/6eee2472-fa4c-46e2-bf92-b211ef430649">
  <source media="(prefers-color-scheme: light)" srcset="https://github.com/user-attachments/assets/b190d8ad-8f1a-47d2-baaa-0823b182a328">
  <img width="850" alt="nixos-dots banner" src="https://github.com/user-attachments/assets/6eee2472-fa4c-46e2-bf92-b211ef430649">
</picture>

[![NixOS](https://img.shields.io/badge/NixOS-unstable-2b2b2b?style=flat-square&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-2b2b2b?style=flat-square&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-configured-2b2b2b?style=flat-square)](https://github.com/nix-community/home-manager)
[![Disko](https://img.shields.io/badge/Disko-declarative%20disks-2b2b2b?style=flat-square)](https://github.com/nix-community/disko)
[![nixos-anywhere](https://img.shields.io/badge/nixos--anywhere-installs-2b2b2b?style=flat-square)](https://github.com/nix-community/nixos-anywhere)

Declarative NixOS system configuration, managed with Flakes, Home Manager & Disko, installed via nixos-anywhere.

</div>

# Overview

This repository holds my complete NixOS setup: system configuration, Home Manager dotfiles, and disk layouts, built entirely from Nix flakes for reproducible, declarative deployment across hosts.

# Philosophy

- **Reproducible.** Every machine should be rebuildable from this repo alone, no manual steps, no "it works on my laptop."
- **Easy to set up.** A fresh install should go from a wiped disk to a fully configured desktop in as few commands as possible.
- **Stateless.** Nothing important should live outside version control. If a machine dies, the config doesn't.
- **Declarative over imperative.** Describe the end state, let Nix figure out how to get there.
- **Secure by default.** Secrets stay out of the store, and the system should fail safe, not silently.

# Preview

<div align="center">

<img width="850" alt="Desktop preview" src="https://github.com/user-attachments/assets/f437ce70-0fe4-4c90-a070-251a1f2e85c2" />

</div>

# Docs

| Guide | Description |
|---|---|
| [Installation](docs/installation.md) | Fresh install via nixos-anywhere, wipe to first boot |
| [Maintenance](docs/maintenance.md) | Updating, rebuilding, and garbage collection |
| [Architecture](docs/architecture.md) | How the flake and modules are organized |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
| [Secrets](docs/secrets.md) | Secrets management |
| [Forking](docs/forking.md) | Rename user, git identity, secrets bootstrap |
| [Per-host: Aspire 7](docs/aspire7.md) | Hardware-specific config for the Aspire 7 |

# Contributing

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](LICENSE)

---

<div align="center">
<sub>This repo changes frequently as the setup evolves. Expect things to shift.</sub>
</div>
