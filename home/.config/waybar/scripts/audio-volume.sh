#!/usr/bin/env bash

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
  text="󰕿 ${volume}%"
  alt="unmuted"
  tooltip="Volume: ${volume}%"
fi

echo "{\"text\": \"${text}\", \"alt\": \"${alt}\", \"tooltip\": \"${tooltip}\"}"
