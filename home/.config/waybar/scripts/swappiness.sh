#!/usr/bin/env bash

if [[ "$1" == "menu" ]]; then
    current=$(sysctl -n vm.swappiness)

    options=(
        "60 (minimal)"
        "100 (conservative)"
        "150 (balanced)"
        "180 (aggressive)"
        "200 (maximum)"
    )

    menu=""
    for option in "${options[@]}"; do
        value=$(echo "$option" | cut -d' ' -f1)
        if [[ "$value" == "$current" ]]; then
            menu="${menu}● $option"$'\n'
        else
            menu="${menu}  $option"$'\n'
        fi
    done

    menu="${menu%$'\n'}"

    selected=$(echo -e "$menu" | rofi -dmenu -p "Swappiness (ZRAM)")

    if [[ -n "$selected" ]]; then
        value=$(echo "$selected" | sed 's/^[●  ]*//' | cut -d' ' -f1)

        echo "$value" | sudo tee /proc/sys/vm/swappiness > /dev/null
        notify-send -i "preferences-system-symbolic" "Swappiness" "Set to $value (runtime only)" -t 2000
    fi
fi
