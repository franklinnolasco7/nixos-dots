{ pkgs, ... }:

{
  home.packages = [
    pkgs.wl-clipboard
    pkgs.wl-clip-persist
  ];
}
