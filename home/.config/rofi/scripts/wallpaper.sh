#!/usr/bin/env bash
set -uo pipefail

WALLPAPER_DIR="$HOME/nixos-dots/themes/wallpapers"
DRY_RUN=0
case "${1:-}" in
    --dry-run) DRY_RUN=1 ;;
    *)         WALLPAPER_DIR="${1:-$WALLPAPER_DIR}" ;;
esac

THUMBNAIL_DIR="$HOME/.cache/rofi-wallpaper"
THUMBNAIL_SIZE="320x180"
ROFI_THEME="$HOME/.config/rofi/theme-wallpaper.rasi"
HISTORY_FILE="$THUMBNAIL_DIR/history"
HISTORY_LIMIT="${ROFI_WALLPAPER_HISTORY_LIMIT:-200}"

TRANSITION_TYPE=grow
TRANSITION_POS=center
TRANSITION_DURATION=1
TRANSITION_FPS=60

declare -A WALLPAPERS

mkdir -p "$THUMBNAIL_DIR"
[[ -f "$HISTORY_FILE" ]] || : > "$HISTORY_FILE"

warn() { printf 'wallpaper: %s\n' "$*" >&2; }

wallpapers() {
    find "$WALLPAPER_DIR" -type f \( \
        -iname '*.jpg'  -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \
        -o -iname '*.tiff' \) | sort
}

thumbnail_path() {
    printf '%s/%s.png' "$THUMBNAIL_DIR" "${1//\//_}"
}

ensure_daemon() {
    pgrep -x awww-daemon >/dev/null || { awww-daemon & sleep 1; }
}

ensure_thumbnail() {
    local img=$1 name=$2 thumb
    thumb="$(thumbnail_path "$name")"
    [[ -f "$thumb" ]] && return 0
    magick "$img" \
        -thumbnail "${THUMBNAIL_SIZE}^" \
        -gravity center \
        -extent "$THUMBNAIL_SIZE" \
        "$thumb" 2>/dev/null \
        || warn "thumbnail failed for $name"
}

index_wallpapers() {
    local img rel name
    while IFS= read -r img; do
        rel="${img#"$WALLPAPER_DIR/"}"
        name="${rel%.*}"
        WALLPAPERS["$name"]="$img"
        ensure_thumbnail "$img" "$name"
    done < <(wallpapers)
}

read_history() {
    mapfile -t history < "$HISTORY_FILE" 2>/dev/null || history=()
}

store_history() {
    local name=$1 tmp
    [[ -n "$name" ]] || return 0
    tmp="$(mktemp)"
    printf '%s\n' "$name" > "$tmp"
    grep -Fxv -- "$name" "$HISTORY_FILE" >> "$tmp" 2>/dev/null || true
    head -n "$HISTORY_LIMIT" "$tmp" > "$HISTORY_FILE"
    rm -f "$tmp"
}

build_menu() {
    local name
    declare -A seen=()
    for name in "${history[@]}"; do
        [[ -z "$name" || ${seen["$name"]+x} || ! ${WALLPAPERS["$name"]+x} ]] && continue
        seen["$name"]=1
        printf '%s\0icon\x1f%s\n' "$name" "$(thumbnail_path "$name")"
    done
    for name in "${!WALLPAPERS[@]}"; do
        [[ ${seen["$name"]+x} ]] && continue
        printf '%s\0icon\x1f%s\n' "$name" "$(thumbnail_path "$name")"
    done | sort
}

apply_wallpaper() {
    awww img "$1" \
        --transition-type "$TRANSITION_TYPE" \
        --transition-pos "$TRANSITION_POS" \
        --transition-duration "$TRANSITION_DURATION" \
        --transition-fps "$TRANSITION_FPS" \
        || warn "failed to apply $1"
}

if [[ "$DRY_RUN" -eq 1 ]]; then
    read_history
    index_wallpapers
    build_menu
    exit 0
fi

ensure_daemon
read_history
index_wallpapers

selection=$(build_menu | rofi \
    -theme "$ROFI_THEME" \
    -dmenu \
    -p "󰸉 " \
    -show-icons \
    -format s)

if [[ -n "$selection" ]]; then
    apply_wallpaper "${WALLPAPERS[$selection]}" && store_history "$selection"
fi
