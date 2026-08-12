{ pkgs, lib, ... }:

let
  settings = [ ];
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "hyprctl-apply" ''
      sleep 3

      ${lib.concatStringsSep "\n" (map (s: "hyprctl keyword ${s.key} ${s.value}") settings)}
    '')
  ];
}
