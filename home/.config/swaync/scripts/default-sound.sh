#!/usr/bin/env bash
[[ "$(swaync-client -D)" == "true" ]] && exit 0
[[ $SWAYNC_APP_NAME == "uair" ]] && exit 0
pw-play "$HOME/.config/swaync/sounds/default.ogg" 2>/dev/null || true
