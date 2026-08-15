{ pkgs, ... }:

{
  audio-volume = pkgs.writeShellScriptBin "audio-volume" ''
    SINK="@DEFAULT_SINK@"
    MAX_VOLUME=600

    if [[ $1 == "up" ]]; then
      current=$(pactl get-sink-volume "$SINK" | grep -oP '\d+(?=%)' | head -1)
      new_volume=$((current + 5))
      if [[ $new_volume -le $MAX_VOLUME ]]; then
        pactl set-sink-volume "$SINK" +5%
      fi
      exit 0
    elif [[ $1 == "down" ]]; then
      pactl set-sink-volume "$SINK" -5%
      exit 0
    fi

    volume=$(pactl get-sink-volume "$SINK" | grep -oP '\d+(?=%)' | head -1)
    muted=$(pactl get-sink-mute "$SINK" | awk '{print $2}')

    if [[ $muted == "yes" ]] || [[ $volume -eq 0 ]]; then
      text="󰖁 MUT"
      alt="muted"
      tooltip="Muted\nVolume: 0%"
    else
      text="󰕿 ''${volume}%"
      alt="unmuted"
      tooltip="Volume: ''${volume}%"
    fi

    echo "{\"text\": \"''${text}\", \"alt\": \"''${alt}\", \"tooltip\": \"''${tooltip}\"}"
  '';

  audio-microphone = pkgs.writeShellScriptBin "audio-microphone" ''
    SOURCE="@DEFAULT_SOURCE@"
    MAX_VOLUME=600

    if [[ $1 == "up" ]]; then
      current=$(pactl get-source-volume "$SOURCE" | grep -oP '\d+(?=%)' | head -1)
      new_volume=$((current + 5))
      if [[ $new_volume -le $MAX_VOLUME ]]; then
        pactl set-source-volume "$SOURCE" +5%
      fi
      exit 0
    elif [[ $1 == "down" ]]; then
      pactl set-source-volume "$SOURCE" -5%
      exit 0
    fi

    volume=$(pactl get-source-volume "$SOURCE" | grep -oP '\d+(?=%)' | head -1)
    muted=$(pactl get-source-mute "$SOURCE" | awk '{print $2}')

    if [[ $muted == "yes" ]] || [[ $volume -eq 0 ]]; then
      text="󰍭 MUT"
      alt="source-muted"
      tooltip="Microphone Muted\nVolume: 0%"
    else
      text="󰍬 ''${volume}%"
      alt="unmuted"
      tooltip="Microphone: ''${volume}%"
    fi

    echo "{\"text\": \"''${text}\", \"alt\": \"''${alt}\", \"tooltip\": \"''${tooltip}\"}"
  '';

  cpu-governor = pkgs.writeShellScriptBin "cpu-governor" ''
    if [[ ''${1:-} != "menu" ]]; then
      exit 0
    fi

    current=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "unknown")

    read -ra governors <<<"$(
      cpupower frequency-info 2>/dev/null \
        | sed -n 's/.*available cpufreq governors: //p' \
        | head -n1
    )"

    if [[ ''${#governors[@]} -eq 0 ]]; then
      notify-send \
        -i dialog-error-symbolic \
        "CPU Governor" \
        "Unable to detect available governors." \
        -t 3000
      exit 1
    fi

    menu=""

    for governor in "''${governors[@]}"; do
      if [[ $governor == "$current" ]]; then
        menu+="● $governor"$'\n'
      else
        menu+="  $governor"$'\n'
      fi
    done

    selected=$(printf '%s' "''${menu%$'\n'}" | rofi -dmenu -sync -p "CPU Governor")

    [[ -z $selected ]] && exit 0

    governor=$(echo "$selected" | sed 's/^[●  ]*//')

    echo "$governor" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null

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
  '';

  swappiness = pkgs.writeShellScriptBin "swappiness" ''
    if [[ $1 == "menu" ]]; then
      current=$(sysctl -n vm.swappiness)

      options=(
        "60 (minimal)"
        "100 (conservative)"
        "150 (balanced)"
        "180 (aggressive)"
        "200 (maximum)"
      )

      menu=""
      for option in "''${options[@]}"; do
        value=$(echo "$option" | cut -d' ' -f1)
        if [[ $value == "$current" ]]; then
          menu="''${menu}● $option"$'\n'
        else
          menu="''${menu}  $option"$'\n'
        fi
      done

      menu="''${menu%$'\n'}"

      selected=$(echo -e "$menu" | rofi -dmenu -p "Swappiness (ZRAM)")

      if [[ -n $selected ]]; then
        value=$(echo "$selected" | tr -d '●' | xargs | cut -d' ' -f1)

        if sudo sysctl -w vm.swappiness="$value" >/dev/null; then
          notify-send -i "preferences-system-symbolic" "Swappiness" "Set to $value (runtime only)" -t 2000
        else
          notify-send -i "dialog-error-symbolic" "Swappiness" "Failed to set $value" -t 3000
        fi
      fi
    fi
  '';

  power-profile = pkgs.writeShellScriptBin "power-profile" ''
    if [[ ''${1:-} != "menu" ]]; then
      exit 0
    fi

    current=$(powerprofilesctl get)

    profiles=(performance balanced power-saver)

    menu=""
    for profile in "''${profiles[@]}"; do
      if [[ $profile == "$current" ]]; then
        menu+="● $profile"$'\n'
      else
        menu+="  $profile"$'\n'
      fi
    done

    # -sync forces rofi to drain stdin before showing the dialog; without it
    # the async reader can drop input on some setups.
    selected=$(printf '%s' "''${menu%$'\n'}" | rofi -dmenu -sync -p "Power Profile")

    [[ -z $selected ]] && exit 0

    profile=$(echo "$selected" | sed 's/^[●  ]*//')

    if powerprofilesctl set "$profile"; then
      notify-send -i "battery-symbolic" "Power Profile" "Set to $profile" -t 2000
    else
      notify-send -u critical -i "dialog-error-symbolic" "Power Profile" \
        "Failed to set $profile" -t 4000
    fi
  '';

  battery-limit-toggle = pkgs.writeShellScriptBin "battery-limit-toggle" ''
    HEALTH_MODE="/sys/bus/wmi/drivers/acer-wmi-battery/health_mode"

    [[ ! -f $HEALTH_MODE ]] && notify-send -u critical -i "battery-symbolic" "Battery Limit" "Driver not loaded" && exit 1

    current=$(cat "$HEALTH_MODE")

    if [[ $current == "1" ]]; then
      echo 0 >"$HEALTH_MODE"
      notify-send -i "battery-full-charging-symbolic" "Battery Charging Limit" \
        "<span color='#f38ba8'>[DISABLED]</span> - Charging to 100%"
    else
      echo 1 >"$HEALTH_MODE"
      notify-send -i "battery-full-charging-symbolic" "Battery Charging Limit" \
        "<span color='#a6e3a1'>[ENABLED]</span> - Stops at 80%"
    fi
  '';

  bluetooth-toggle = pkgs.writeShellScriptBin "bluetooth-toggle" ''
    if rfkill list bluetooth | grep -q "Soft blocked: no"; then
      rfkill block bluetooth
    else
      rfkill unblock bluetooth
    fi
  '';

  wifi-toggle = pkgs.writeShellScriptBin "wifi-toggle" ''
    if nmcli radio wifi | grep -q "enabled"; then
      nmcli radio wifi off
    else
      nmcli radio wifi on
    fi
  '';
}
