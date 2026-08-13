{
  lib,
  profile,
  ...
}:

{
  imports = [
    ./micro
  ]
  ++ lib.optionals (profile == "full") [
    # TUI/agent editor — full profile only.
    ./opencode
  ];
}
