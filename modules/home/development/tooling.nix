{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # JavaScript / TypeScript
    nodejs
    pnpm
    bun

    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # Rust
    rustc
    cargo

    # Build tools
    gcc
    gnumake
    pkg-config

    # This repo's formatters (install/format.sh looks them up on PATH)
    nixfmt
    stylua
    shfmt
    taplo
  ];
}
