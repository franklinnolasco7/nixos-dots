{
  config,
  lib,
  pkgs,
  ...
}:

let
  mkToggle = import ./mk-toggle.nix { inherit config lib pkgs; };
in
{
  home.packages = [
    (mkToggle {
      name = "toggle-laptop-tp";
      stateFile = "laptop_tp_state";
      device = "elan050a:00-04f3:3158-touchpad";
      icon = "input-touchpad-symbolic";
      title = "Touchpad";
    })
  ];
}
