{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nodejs
    pnpm
    bun

    python3
    python3Packages.pip
    python3Packages.virtualenv

    rustc
    cargo

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
