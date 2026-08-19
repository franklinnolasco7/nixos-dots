{ pkgs }:

let
  colors = import ../styling/palette.nix;
in
{
  name,
  stateFile,
  device,
  icon,
  title,
}:
pkgs.writeShellScriptBin name ''
  STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/${stateFile}"

  is_disabled() {
    [[ -f $STATE_FILE ]] && [[ "$(cat "$STATE_FILE")" == "true" ]]
  }

  apply() {
    local target="$1"
    local current
    is_disabled && current="true" || current="false"

    [[ $target == "$current" ]] && return

    echo "$target" >"$STATE_FILE"

    if [[ $target == "true" ]]; then
      hyprctl eval 'hl.device({ name = "${device}", enabled = false })'
      notify-send -i "${icon}" "${title}" \
        "<span color='${colors.notifyDanger}'>[DISABLED]</span>"
    else
      hyprctl eval 'hl.device({ name = "${device}", enabled = true })'
      notify-send -i "${icon}" "${title}" \
        "<span color='${colors.notifySuccess}'>[ENABLED]</span>"
    fi
  }

  restore() {
    if is_disabled; then
      hyprctl eval 'hl.device({ name = "${device}", enabled = false })'
    else
      hyprctl eval 'hl.device({ name = "${device}", enabled = true })'
    fi
  }

  case "''${1:-toggle}" in
    status)
      is_disabled && echo "true" || echo "false"
      ;;
    restore)
      restore
      ;;
    apply)
      case "$2" in
        true | false) apply "$2" ;;
        *) is_disabled && apply "false" || apply "true" ;;
      esac
      ;;
    *)
      is_disabled && apply "false" || apply "true"
      ;;
  esac
''
