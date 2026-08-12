{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "airplane-mode" ''
      STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/airplane_mode_state"

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

      case "''${1:-toggle}" in
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
    '')

    (pkgs.writeShellScriptBin "annotate-last-screenshot" ''
      SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
      latest=$(ls -t "$SCREENSHOT_DIR"/*.png 2>/dev/null | head -n 1)

      [[ -z $latest ]] && echo "No screenshots found" >&2 && exit 1

      satty -f "$latest" --copy-command 'wl-copy' --early-exit --output-filename "$latest" || {
        echo "Could not open satty" >&2
        exit 1
      }
    '')

    (pkgs.writeShellScriptBin "battery-notify" ''
      set -u

      BATTERY=/sys/class/power_supply/BAT1
      STATE_FILE=/tmp/battery-notify
      POLL_SECONDS=''${POLL_SECONDS:-3}
      WARN=''${WARN:-25}
      CRIT=''${CRIT:-15}
      URGENT=''${URGENT:-5}

      notify() {
        local level="$1"
        local icon="$2"
        local msg="$3"
        if command -v notify-send >/dev/null 2>&1; then
          notify-send -u "$level" -i "$icon" -a battery "Battery ''${level}" "$msg"
        fi
        echo "$level" >"$STATE_FILE"
      }

      charging() {
        local last
        local icon="battery-level-$((capacity / 10 * 10))-charging-symbolic"
        last=$(cat "$STATE_FILE" 2>/dev/null || true)
        if [[ $last == "" ]]; then
          echo "charging" >"$STATE_FILE"
        elif [[ $last != "charging" ]]; then
          notify-send -i "$icon" -a battery "Battery" "Charging at ''${capacity}%."
          echo "charging" >"$STATE_FILE"
        fi
      }

      while true; do
        if [[ -f "$BATTERY/capacity" ]]; then
          capacity=$(<"$BATTERY/capacity")
          status=$(<"$BATTERY/status")

          if [[ $status == "Discharging" ]]; then
            if ((capacity <= URGENT)); then
              level=urgent
            elif ((capacity <= CRIT)); then
              level=critical
            elif ((capacity <= WARN)); then
              level=warning
            else
              level=ok
            fi

            last=$(cat "$STATE_FILE" 2>/dev/null || true)
            if [[ $level != "ok" ]]; then
              if [[ $last != "$level" ]]; then
                case "$level" in
                  warning) notify normal "battery-low-symbolic" "Battery at ''${capacity}%. Plug in soon." ;;
                  critical) notify critical "battery-caution-symbolic" "Battery at ''${capacity}%. Find a charger." ;;
                  urgent) notify critical "battery-empty-symbolic" "Battery at ''${capacity}%. Device will shut down soon." ;;
                esac
              fi
            else
              if [[ $last == "" ]]; then
                echo "discharging" >"$STATE_FILE"
              elif [[ $last != "discharging" ]]; then
                uicon="battery-level-$((capacity / 10 * 10))-symbolic"
                notify-send -i "$uicon" -a battery "Battery" "Unplugged at ''${capacity}%."
                echo "discharging" >"$STATE_FILE"
              fi
            fi
          else
            charging
          fi
        fi
        sleep "$POLL_SECONDS"
      done
    '')

    (pkgs.writeShellScriptBin "toggle-laptop-kb" ''
      STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/laptop_kb_state"

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
          hyprctl eval 'hl.device({ name = "at-translated-set-2-keyboard", enabled = false })'
          notify-send -i "input-keyboard-symbolic" "Built-in Keyboard" \
            "<span color='#f38ba8'>[DISABLED]</span>"
        else
          hyprctl eval 'hl.device({ name = "at-translated-set-2-keyboard", enabled = true })'
          notify-send -i "input-keyboard-symbolic" "Built-in Keyboard" \
            "<span color='#a6e3a1'>[ENABLED]</span>"
        fi
      }

      restore() {
        if is_disabled; then
          hyprctl eval 'hl.device({ name = "at-translated-set-2-keyboard", enabled = false })'
        else
          hyprctl eval 'hl.device({ name = "at-translated-set-2-keyboard", enabled = true })'
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
    '')

    (pkgs.writeShellScriptBin "toggle-laptop-tp" ''
      STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/laptop_tp_state"

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
    '')

    (pkgs.writeShellScriptBin "vpn-toggle" ''
      INTERFACE="''${VPN_INTERFACE:-wg0}"
      STATE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/vpn_state"

      is_connected() {
        ip link show "$INTERFACE" &>/dev/null
      }

      get_location() {
        local info
        for i in {1..3}; do
          info=$(timeout 5 curl -sf "https://ipinfo.io/json" 2>/dev/null)
          [[ -n $info ]] && break
          sleep 1
        done

        [[ -z $info ]] && echo "Unknown" && return

        local city country
        city=$(echo "$info" | jq -r '.city // ""')
        country=$(echo "$info" | jq -r '.country // "XX"')

        [[ -n $city ]] && echo "$city [$country]" || echo "[$country]"
      }

      wait_for_tunnel() {
        sleep 2
        for i in {1..10}; do
          ping -c 1 -W 1 1.1.1.1 &>/dev/null && return 0
          sleep 1
        done
        return 1
      }

      connect() {
        if is_connected; then
          notify-send -i "network-vpn-symbolic" "VPN" "Already connected"
          return 0
        fi

        sudo rm -f /run/resolvconf/lock

        err=$(sudo wg-quick up "$INTERFACE" 2>&1) || {
          sudo resolvconf -u &>/dev/null
          notify-send -u critical -i "network-vpn-symbolic" "VPN Error" "Failed to connect: ''${err:-unknown error}"
          return 1
        }

        sudo resolvconf -u &>/dev/null

        echo "true" >"$STATE_FILE"
        notify-send -i "network-vpn-symbolic" "VPN" "Connecting..."

        (
          if wait_for_tunnel; then
            local loc
            loc=$(get_location)
            notify-send -i "network-vpn-symbolic" "VPN Connected" "<span color='#a6e3a1'>''${loc:-Unknown}</span>"
          else
            notify-send -u critical -i "network-vpn-symbolic" "VPN Error" "Tunnel established but no connectivity"
          fi
        ) &
      }

      disconnect() {
        if ! is_connected; then
          notify-send -i "network-vpn-symbolic" "VPN" "Already disconnected"
          return 0
        fi

        sudo rm -f /run/resolvconf/lock

        err=$(sudo wg-quick down "$INTERFACE" 2>&1) || {
          sudo resolvconf -u &>/dev/null
          notify-send -u critical -i "network-vpn-symbolic" "VPN Error" "Failed to disconnect: ''${err:-unknown error}"
          return 1
        }

        sudo resolvconf -u &>/dev/null

        echo "false" >"$STATE_FILE"
        notify-send -i "network-vpn-symbolic" "VPN Disconnected" "<span color='#f38ba8'>[OFF]</span>"
      }

      case "''${1:-toggle}" in
        status)
          is_connected && echo "true" || echo "false"
          ;;
        apply)
          case "$2" in
            true) is_connected || connect ;;
            false) is_connected && disconnect ;;
            *) is_connected && disconnect || connect ;;
          esac
          ;;
        *)
          is_connected && disconnect || connect
          ;;
      esac
    '')
  ];
}
