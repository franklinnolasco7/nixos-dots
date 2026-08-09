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
    git
    gcc
    gnumake
    pkg-config
  ];
}