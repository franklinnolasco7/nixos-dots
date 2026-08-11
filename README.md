<div align="center">

**Declarative NixOS system configuration, managed with Flakes, Home Manager & Disko.**

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?style=for-the-badge&logo=nixos&logoColor=white)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Flakes-enabled-blue?style=for-the-badge&logo=nixos&logoColor=white)](https://nixos.wiki/wiki/Flakes)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-configured-7EBAE4?style=for-the-badge)](https://github.com/nix-community/home-manager)
[![Disko](https://img.shields.io/badge/Disko-declarative%20disks-orange?style=for-the-badge)](https://github.com/nix-community/disko)

</div>

<br>

<p align="center">
  <img width="100%" alt="Desktop preview" src="https://github.com/user-attachments/assets/f437ce70-0fe4-4c90-a070-251a1f2e85c2" />
</p>

<br>

## Overview

This repository holds my complete NixOS setup: system configuration, Home Manager dotfiles, and disk layouts, built entirely from Nix flakes for reproducible, declarative deployment across hosts.

The goal is simple: a system that's fully reproducible and easy to set up on anything, from a fresh install to a running desktop in one command.

<br>

## Docs

| Guide | Description |
|---|---|
| [Installation](docs/installation.md) | Fresh install, from ISO to first boot |
| [Maintenance](docs/maintenance.md) | Updating, rebuilding, and garbage collection |
| [Architecture](docs/architecture.md) | How the flake and modules are organized |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |
| [Secrets](docs/secrets.md) | Secrets management |
| [Per-host: Aspire 7](docs/aspire7.md) | Hardware-specific config for the Aspire 7 |
| [Theme: Dimspectra](themes/dimspectra.md) | The visual theme powering this setup |

<br>

## Contributing

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [License](LICENSE)
