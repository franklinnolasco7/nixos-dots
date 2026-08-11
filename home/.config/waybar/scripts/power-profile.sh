#!/usr/bin/env bash

if [[ $1 == "menu" ]]; then
  current=$(powerprofilesctl get)

  options=("performance" "balanced" "power-saver")

  menu=""
  for profile in "${options[@]}"; do
    if [[ $profile == "$current" ]]; then
      menu="${menu}● $profile"$'\n'
    else
      menu="${menu}  $profile"$'\n'
    fi
  done

  menu="${menu%$'\n'}"

  selected=$(echo -e "$menu" | rofi -dmenu -p "Power Profile")

  if [[ -n $selected ]]; then
    profile=$(echo "$selected" | sed 's/^[●  ]*//')
    powerprofilesctl set "$profile"
    notify-send -i "battery-symbolic" "Power Profile" "Set to $profile" -t 2000
  fi
fi
