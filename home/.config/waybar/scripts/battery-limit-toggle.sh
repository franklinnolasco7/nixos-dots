#!/usr/bin/env bash

HEALTH_MODE="/sys/bus/wmi/drivers/acer-wmi-battery/health_mode"

[[ ! -f "$HEALTH_MODE" ]] && notify-send -u critical -i "battery-symbolic" "Battery Limit" "Driver not loaded" && exit 1

current=$(cat "$HEALTH_MODE")

if [[ "$current" == "1" ]]; then
    echo 0 > "$HEALTH_MODE"
    notify-send -i "battery-full-charging-symbolic" "Battery Charging Limit" \
        "<span color='#f38ba8'>[DISABLED]</span> - Charging to 100%"
else
    echo 1 > "$HEALTH_MODE"
    notify-send -i "battery-full-charging-symbolic" "Battery Charging Limit" \
        "<span color='#a6e3a1'>[ENABLED]</span> - Stops at 80%"
fi
