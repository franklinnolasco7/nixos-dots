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
        value=$(echo "$selected" | tr -d '●' | xargs | cut -d' ' -f1)

        if sudo sysctl -w vm.swappiness="$value" > /dev/null; then
            notify-send -i "preferences-system-symbolic" "Swappiness" "Set to $value (runtime only)" -t 2000
        else
            notify-send -i "dialog-error-symbolic" "Swappiness" "Failed to set $value" -t 3000
        fi
    fi
fi
