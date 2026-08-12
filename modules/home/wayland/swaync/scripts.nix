{ pkgs }:

let
  mkSoundScript =
    name: sound:
    pkgs.writeShellScriptBin name ''
      [[ "$(swaync-client -D)" == "true" ]] && exit 0
      [[ $SWAYNC_APP_NAME == "uair" ]] && exit 0
      pw-play "${sound}" 2>/dev/null || true
    '';
in
{
  default-sound = mkSoundScript "swaync-default-sound" ./sounds/default.ogg;
  critical-sound = mkSoundScript "swaync-critical-sound" ./sounds/important.ogg;
}
