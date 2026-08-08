#!/usr/bin/env bash

set -u

BATTERY=/sys/class/power_supply/BAT1
STATE_FILE=/tmp/battery-notify
POLL_SECONDS=${POLL_SECONDS:-3}
WARN=${WARN:-25}
CRIT=${CRIT:-15}
URGENT=${URGENT:-5}

notify() {
	local level="$1"
	local icon="$2"
	local msg="$3"
	if command -v notify-send >/dev/null 2>&1; then
		notify-send -u "$level" -i "$icon" -a battery "Battery ${level}" "$msg"
	fi
	echo "$level" > "$STATE_FILE"
}

charging() {
	local last
	local icon="battery-level-$((capacity / 10 * 10))-charging-symbolic"
	last=$(cat "$STATE_FILE" 2>/dev/null || true)
	if [[ "$last" == "" ]]; then
		echo "charging" > "$STATE_FILE"
	elif [[ "$last" != "charging" ]]; then
		notify-send -i "$icon" -a battery "Battery" "Charging at ${capacity}%."
		echo "charging" > "$STATE_FILE"
	fi
}

while true; do
	if [[ -f "$BATTERY/capacity" ]]; then
		capacity=$(<"$BATTERY/capacity")
		status=$(<"$BATTERY/status")

		if [[ "$status" == "Discharging" ]]; then
			if (( capacity <= URGENT )); then
				level=urgent
			elif (( capacity <= CRIT )); then
				level=critical
			elif (( capacity <= WARN )); then
				level=warning
			else
				level=ok
			fi

			last=$(cat "$STATE_FILE" 2>/dev/null || true)
			if [[ "$level" != "ok" ]]; then
				if [[ "$last" != "$level" ]]; then
					case "$level" in
						warning)  notify normal "battery-low-symbolic" "Battery at ${capacity}%. Plug in soon." ;;
						critical) notify critical "battery-caution-symbolic" "Battery at ${capacity}%. Find a charger." ;;
						urgent)   notify critical "battery-empty-symbolic" "Battery at ${capacity}%. Device will shut down soon." ;;
					esac
				fi
			else
				if [[ "$last" == "" ]]; then
					echo "discharging" > "$STATE_FILE"
				elif [[ "$last" != "discharging" ]]; then
					uicon="battery-level-$((capacity / 10 * 10))-symbolic"
					notify-send -i "$uicon" -a battery "Battery" "Unplugged at ${capacity}%."
					echo "discharging" > "$STATE_FILE"
				fi
			fi
		else
			charging
		fi
	fi
	sleep "$POLL_SECONDS"
done