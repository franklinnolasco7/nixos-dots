#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/config.rasi"
CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr_keybinds_cache"
CACHE_TIMEOUT=3600  # 1 hour in seconds
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_SOURCES=(
    "$HOME/.config/hypr/hyprland.lua"
)

normalize_modifiers() {
    local modifier="$1"
    modifier=${modifier//\$mainMod/󰘳}
    modifier=${modifier//SUPER/󰘳}
    modifier=${modifier//SHIFT/Shift}
    modifier=${modifier//CTRL/Ctrl}
    modifier=${modifier//Control/Ctrl}
    modifier=${modifier//ALT/Alt}
    modifier=$(echo "$modifier" | sed 's/^ *//; s/ *$//; s/  */ /g')
    modifier=${modifier// / + }
    echo "$modifier"
}

truncate_text() {
    local text="$1" max=${2:-64}
    if [[ -n "$text" && ${#text} -gt $max ]]; then
        echo "${text:0:$(($max-3))}..."
    else
        echo "$text"
    fi
}

format_display() {
    local modifier="$1" key="$2" action="$3" note="$4" prefix="$5" data="${6:-$3|$4}"
    local normalized label note_display body

    normalized=$(normalize_modifiers "$modifier")
    if [[ -n "$normalized" ]]; then
        label="$normalized + $key"
    else
        label="$key"
    fi

    note_display=$(truncate_text "$note")

    if [[ -n "$note_display" ]]; then
        body=$(printf "<b>%s</b>  <i>%s</i>  <span color='gray'>%s</span>" "$label" "$action" "$note_display")
    else
        body=$(printf "<b>%s</b>  <i>%s</i>" "$label" "$action")
    fi

    if [[ -n "$prefix" ]]; then
        printf "%s\t%s\t%s\n" "$prefix" "$body" "$data"
    else
        printf "\t%s\t%s\n" "$body" "$data"
    fi
}

collect_bindings_from_lua() {
    local source="$1"
    [[ -r "$source" ]] || return
    command -v lua >/dev/null 2>&1 || return

    lua "$SCRIPT_DIR/hypr-keybinds.lua" "$source" | \
    while IFS=$'\t' read -r modifier key action arg flags; do
        [[ -z "$action" || "$action" == "__"* ]] && continue
        local note="$arg"
        [[ -n "$flags" ]] && note="$note [${flags}]"
        format_display "$modifier" "$key" "$action" "$note" "" "$action|$arg"
    done
}

cache_fresh=false
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    [[ $cache_age -lt $CACHE_TIMEOUT ]] && cache_fresh=true
fi

if [[ "$cache_fresh" == false ]] || [[ "$1" == "--rebuild" ]]; then
    {
        for source in "${CONFIG_SOURCES[@]}"; do
            collect_bindings_from_lua "$source"
        done

        for mode in next previous; do
            mapfile -t combos < <(sed -n "s/.*kb-mode-${mode}:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$ROFI_THEME" | tr ',' '\n')
            for combo in "${combos[@]}"; do
                [[ -z "$combo" ]] && continue
                kb_mod="${combo%%+*}" kb_key="${combo#*+}"
                kb_mod=$(echo "$kb_mod" | sed 's/^ *//; s/ *$//')
                kb_key=$(echo "$kb_key" | sed 's/^ *//; s/ *$//')
                format_display "$kb_mod" "$kb_key" "rofi → switch to ${mode} mode" "config.rasi • kb-mode-${mode}"
            done
        done
    } > "$CACHE_FILE"
fi

mapfile -t lines < "$CACHE_FILE"

[[ ${#lines[@]} -eq 0 ]] && { notify-send "Hypr keybinds" "No bindings found"; exit 0; }

list_lines=${#lines[@]}
(( list_lines > 12 )) && list_lines=12

result=$(printf '%s\n' "${lines[@]}" \
    | cut -f1,2 \
    | sed 's/\t/  /' \
    | rofi -dmenu -i -format 'i s' -markup-rows -p "󰌌" -theme "$ROFI_THEME" \
        -theme-str 'window { width: 820px; }' \
        -theme-str "listview { lines: ${list_lines}; spacing: 6px; }" \
        -theme-str 'element-text { font: "JetBrainsMono Nerd Font Mono 12"; }' \
        -theme-str 'message { enabled: true; padding: 4px 16px; }' \
        -mesg "<span size='large'><b>Hyprland Keybinds</b></span>")


[[ -z "$result" ]] && exit 0

read -r index _ <<< "$result"
action_data="${lines[$index]##*$'\t'}"

IFS='|' read -r action param <<< "$action_data"

if [[ "$action" == "exec" ]]; then
    eval "$param" &
elif [[ -n "$action" && "$action" != "rofi"* && "$action" != "macro"* ]]; then
    [[ -n "$param" ]] && hyprctl dispatch "$action" "$param" || hyprctl dispatch "$action"
fi
