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
      name = "toggle-laptop-kb";
      stateFile = "laptop_kb_state";
      device = "at-translated-set-2-keyboard";
      icon = "input-keyboard-symbolic";
      title = "Built-in Keyboard";
    })
  ];
}
