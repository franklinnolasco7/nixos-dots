#!/usr/bin/env bash

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
  text="󰍬 ${volume}%"
  alt="unmuted"
  tooltip="Microphone: ${volume}%"
fi

echo "{\"text\": \"${text}\", \"alt\": \"${alt}\", \"tooltip\": \"${tooltip}\"}"
