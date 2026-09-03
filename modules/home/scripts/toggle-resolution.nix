{
  config,
  lib,
  pkgs,
  ...
}:

let
  raw = config.myPalette;
  colors = lib.mapAttrs (_: v: "#${v}") raw;
  monitor = "eDP-1";
  modes = [
    "1080"
    "810"
  ];
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "toggle-resolution" ''
      STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/resolution_state"
      MONITOR="${monitor}"
      ICON="video-display-symbolic"
      TITLE="Display Resolution"

      MODES=(${(lib.concatMapStringsSep " " (m: "\"${m}\"") modes)})
      NATIVE_H="''${MODES[0]}"

      current_height() {
        if [[ -f $STATE_FILE ]]; then
          cat "$STATE_FILE"
        else
          echo "$NATIVE_H"
        fi
      }

      other_height() {
        local cur="$1"
        for m in "''${MODES[@]}"; do
          [[ $m != "$cur" ]] && {
            echo "$m"
            return
          }
        done
      }

      apply() {
        local h="$1"
        echo "$h" >"$STATE_FILE"
        hyprctl eval "hl.monitor({output=\"$MONITOR\", mode=\"1920x''${h}@60\", position=\"0x0\", scale=1})"
        if [[ $h == "$NATIVE_H" ]]; then
          notify-send -i "$ICON" "$TITLE" \
            "<span color='${colors.base0B}'>[NATIVE 1920x''${h}]</span>"
        else
          notify-send -i "$ICON" "$TITLE" \
            "<span color='${colors.base08}'>[CUSTOM 1920x''${h}]</span>"
        fi
      }

      restore() {
        apply "$(current_height)"
      }

      case "''${1:-toggle}" in
        status)
          current_height
          ;;
        restore)
          restore
          ;;
        apply)
          case "$2" in
            ${lib.concatStringsSep "|" modes}) apply "$2" ;;
            *) apply "$(other_height "$(current_height)")" ;;
          esac
          ;;
        *)
          apply "$(other_height "$(current_height)")"
          ;;
      esac
    '')
  ];
}
