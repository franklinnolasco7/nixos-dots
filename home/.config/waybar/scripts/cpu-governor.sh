#!/usr/bin/env bash

if [[ "${1:-}" != "menu" ]]; then
    exit 0
fi

current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

read -ra governors <<< "$(
    cpupower frequency-info 2>/dev/null |
        sed -n 's/.*available cpufreq governors: //p' |
        head -n1
)"

if [[ ${#governors[@]} -eq 0 ]]; then
    notify-send \
        -i dialog-error-symbolic \
        "CPU Governor" \
        "Unable to detect available governors." \
        -t 3000
    exit 1
fi

menu=""

for governor in "${governors[@]}"; do
    if [[ "$governor" == "$current" ]]; then
        menu+="● $governor"$'\n'
    else
        menu+="  $governor"$'\n'
    fi
done

selected=$(printf '%s' "${menu%$'\n'}" | rofi -dmenu -p "CPU Governor")

[[ -z "$selected" ]] && exit 0

governor="${selected#* }"

sudo cpupower frequency-set -g "$governor"

if [[ $? -eq 0 ]]; then
    notify-send \
        -i preferences-system-symbolic \
        "CPU Governor" \
        "Set to $governor" \
        -t 2000
else
    notify-send \
        -i dialog-error-symbolic \
        "CPU Governor" \
        "Failed to set $governor" \
        -t 3000
    exit 1
fi