#!/usr/bin/env bash

if [[ "$1" == "menu" ]]; then
    current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

    options=("performance" "powersave")
    menu=""
    for governor in "${options[@]}"; do
        [[ "$governor" == "$current" ]] && menu+="● $governor"$'\n' || menu+="  $governor"$'\n'
    done

    selected=$(echo -e "${menu%$'\n'}" | rofi -dmenu -p "CPU Governor")

    if [[ -n "$selected" ]]; then
        governor="${selected#* }"
        sudo cpupower frequency-set -g "$governor"
        notify-send -i "preferences-system-symbolic" "CPU Governor" "Set to $governor" -t 2000
    fi
fi


