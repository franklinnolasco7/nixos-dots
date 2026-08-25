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



