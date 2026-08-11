#!/usr/bin/env bash

STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/airplane_mode_state"

mkdir -p "$(dirname "$STATE_FILE")"

is_blocked() {
  rfkill list wifi bluetooth 2>/dev/null | grep -q "Soft blocked: yes"
}

apply() {
  local target="$1"
  local current
  is_blocked && current="true" || current="false"

  [[ $target == "$current" ]] && return

  echo "$target" >"$STATE_FILE"

  if [[ $target == "true" ]]; then
    rfkill block wifi bluetooth
    notify-send -i "airplane-mode-symbolic" "Airplane Mode" "[ON]"
  else
    rfkill unblock wifi bluetooth
    notify-send -i "airplane-mode-disabled-symbolic" "Airplane Mode" "[OFF]"
  fi
}

if [[ -f $STATE_FILE ]] && [[ -z $1 || $1 == "restore" ]]; then
  saved_state=$(cat "$STATE_FILE")
  is_blocked && current="true" || current="false"
  if [[ $saved_state != "$current" ]]; then
    if [[ $saved_state == "true" ]]; then
      rfkill block wifi bluetooth
    else
      rfkill unblock wifi bluetooth
    fi
  fi
  exit 0
fi

case "${1:-toggle}" in
  status)
    is_blocked && echo "true" || echo "false"
    ;;
  apply)
    case "$2" in
      true | false) apply "$2" ;;
      *) is_blocked && apply "false" || apply "true" ;;
    esac
    ;;
  *)
    is_blocked && apply "false" || apply "true"
    ;;
esac
