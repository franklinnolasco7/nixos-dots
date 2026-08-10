#!/usr/bin/env bash

STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/laptop_tp_state"

is_disabled() {
    [[ -f "$STATE_FILE" ]] && [[ "$(cat "$STATE_FILE")" == "true" ]]
}

apply() {
    local target="$1"
    local current
    is_disabled && current="true" || current="false"

    [[ "$target" == "$current" ]] && return

    echo "$target" > "$STATE_FILE"

    if [[ "$target" == "true" ]]; then
        hyprctl eval 'hl.device({ name = "elan050a:00-04f3:3158-touchpad", enabled = false })'
        notify-send -i "input-touchpad-symbolic" "Touchpad" \
            "<span color='#f38ba8'>[DISABLED]</span>"
    else
        hyprctl eval 'hl.device({ name = "elan050a:00-04f3:3158-touchpad", enabled = true })'
        notify-send -i "input-touchpad-symbolic" "Touchpad" \
            "<span color='#a6e3a1'>[ENABLED]</span>"
    fi
}

restore() {
    if is_disabled; then
        hyprctl eval 'hl.device({ name = "elan050a:00-04f3:3158-touchpad", enabled = false })'
    else
        hyprctl eval 'hl.device({ name = "elan050a:00-04f3:3158-touchpad", enabled = true })'
    fi
}

case "${1:-toggle}" in
    status)
        is_disabled && echo "true" || echo "false"
        ;;
    restore)
        restore
        ;;
    apply)
        case "$2" in
            true|false) apply "$2" ;;
            *) is_disabled && apply "false" || apply "true" ;;
        esac
        ;;
    *)
        is_disabled && apply "false" || apply "true"
        ;;
esac
