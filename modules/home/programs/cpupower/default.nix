{ pkgs, ... }:

{
  home.packages = [ pkgs.linuxPackages.cpupower ];
}
