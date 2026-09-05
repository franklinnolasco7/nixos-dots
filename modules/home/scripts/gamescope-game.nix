{
  config,
  lib,
  pkgs,
  ...
}:

let
  nestedW = "1920";
  nestedH = "810";
  refresh = "60";
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "gamescope-game" ''
      # gamescope-game <command...>
      # Wrap a game in gamescope at a 1920x810 nested Wayland output, fullscreen
      # on the current desktop. The game sees a fresh virtual wl_output and
      # reports the 21:9 surface to its resolution enumerator, which sidesteps
      # games that ignore or cache the host Wayland mode (e.g. Albion Online
      # launcher). The host panel can stay at 1920x1080 (gamescope upscales) or
      # be at 1920x810 (1:1); both work.
      #
      # For Steam games, prefer setting the launch options in-game:
      #   gamescope -w 1920 -h 810 -W 1920 -H 810 -r 60 -f -F fsr -- %command%
      exec nvidia-offload gamescope \
        --backend wayland \
        -w ${nestedW} -h ${nestedH} \
        -W ${nestedW} -H ${nestedH} \
        -r ${refresh} \
        -f \
        -F fsr \
        -- \
        "$@"
    '')
  ];
}
