#!/usr/bin/env bash

INTERFACE="${VPN_INTERFACE:-wg0}"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/vpn_state"

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
    notify-send -u critical -i "network-vpn-symbolic" "VPN Error" "Failed to connect: ${err:-unknown error}"
    return 1
  }

  sudo resolvconf -u &>/dev/null

  echo "true" >"$STATE_FILE"
  notify-send -i "network-vpn-symbolic" "VPN" "Connecting..."

  (
    if wait_for_tunnel; then
      local loc
      loc=$(get_location)
      notify-send -i "network-vpn-symbolic" "VPN Connected" "<span color='#a6e3a1'>${loc:-Unknown}</span>"
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
    notify-send -u critical -i "network-vpn-symbolic" "VPN Error" "Failed to disconnect: ${err:-unknown error}"
    return 1
  }

  sudo resolvconf -u &>/dev/null

  echo "false" >"$STATE_FILE"
  notify-send -i "network-vpn-symbolic" "VPN Disconnected" "<span color='#f38ba8'>[OFF]</span>"
}

case "${1:-toggle}" in
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
