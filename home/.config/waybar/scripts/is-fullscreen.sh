#!/usr/bin/env bash

if hyprctl -j activewindow 2>/dev/null | jq -e '.fullscreen == true' >/dev/null; then
  echo true
else
  echo false
fi
