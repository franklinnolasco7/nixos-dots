#!/bin/bash

set -uo pipefail

HISTORY_FILE="${XDG_RUNTIME_DIR:-/tmp}/rofi-web-search-history"
HISTORY_LIMIT=${ROFI_WEB_SEARCH_HISTORY_LIMIT:-200}
SEARCH_BASE_URL="${ROFI_WEB_SEARCH_BASE:-https://duckduckgo.com/?q=}"
ROFI_THEME_PATH="${ROFI_WEB_SEARCH_THEME:-$HOME/.config/rofi/config.rasi}"
PROMPT_LABEL="${ROFI_WEB_SEARCH_PROMPT:-}"

BOOKMARKS_FILE="${ROFI_WEB_SEARCH_BOOKMARKS:-${XDG_DATA_HOME:-$HOME/.local/share}/rofi-web-search-bookmarks}"
BOOKMARKS_LIMIT=${ROFI_WEB_SEARCH_BOOKMARKS_LIMIT:-25}
BOOKMARK_ICON="${ROFI_WEB_SEARCH_BOOKMARK_ICON:-user-bookmarks-symbolic}"
BOOKMARK_KEY="${ROFI_WEB_SEARCH_BOOKMARK_KEY:-Control+f}"

history=()
bookmarks=()
declare -A bookmarks_set=()

mkdir -p "$(dirname "$HISTORY_FILE")"
[[ -f "$HISTORY_FILE" ]] || : > "$HISTORY_FILE"
mkdir -p "$(dirname "$BOOKMARKS_FILE")"
[[ -f "$BOOKMARKS_FILE" ]] || : > "$BOOKMARKS_FILE"

read_history() {
    mapfile -t history < "$HISTORY_FILE" 2>/dev/null || history=()
}

read_bookmarks() {
    mapfile -t bookmarks < "$BOOKMARKS_FILE" 2>/dev/null || bookmarks=()
}

index_bookmarks() {
    local key
    for key in "${!bookmarks_set[@]}"; do
        unset 'bookmarks_set[$key]'
    done

    local bookmark
    for bookmark in "${bookmarks[@]}"; do
        [[ -n "$bookmark" ]] && bookmarks_set["$bookmark"]=1
    done
}

show_rofi() {
    {
        declare -A seen=()

        if ((${#bookmarks[@]})); then
            local bookmark
            for bookmark in "${bookmarks[@]}"; do
                [[ -z "$bookmark" || ${seen["$bookmark"]+x} ]] && continue
                seen["$bookmark"]=1
                printf '%s\x00icon\x1f%s\n' "$bookmark" "$BOOKMARK_ICON"
            done
        fi

        if ((${#history[@]})); then
            local entry
            for entry in "${history[@]}"; do
                [[ -z "$entry" || ${seen["$entry"]+x} ]] && continue
                seen["$entry"]=1
                printf '%s\n' "$entry"
            done
        fi

        if (( ${#bookmarks[@]} == 0 && ${#history[@]} == 0 )); then
            printf ''
        fi
    } | rofi -dmenu -i -p "$PROMPT_LABEL" -theme "$ROFI_THEME_PATH" -show-icons -kb-custom-1 "$BOOKMARK_KEY" -kb-move-char-forward ""
}

urlencode() {
    local input="$1"
    local length=${#input}
    local i char
    for (( i=0; i<length; i++ )); do
        char=${input:i:1}
        case "$char" in
            [a-zA-Z0-9._~-])
                printf '%s' "$char"
                ;;
            ' ')
                printf '%s' '+'
                ;;
            *)
                printf '%%%02X' "'${char}'"
                ;;
        esac
    done
}

store_history() {
    local entry="$1"
    if [[ ${bookmarks_set["$entry"]+x} ]]; then
        return
    fi

    local tmp
    tmp=$(mktemp)

    printf '%s\n' "$entry" > "$tmp"
    if [[ -f "$HISTORY_FILE" ]]; then
        grep -Fxv "$entry" "$HISTORY_FILE" >> "$tmp" || true
    fi
    head -n "$HISTORY_LIMIT" "$tmp" > "$HISTORY_FILE"
    rm -f "$tmp"
}

notify_bookmark() {
    command -v notify-send >/dev/null 2>&1 || return 0
    local action="$1"
    local entry="$2"
    local app="${ROFI_WEB_SEARCH_NOTIFY_APP:-Rofi Web Search}"
    local icon="${ROFI_WEB_SEARCH_NOTIFY_ICON:-user-bookmarks-symbolic}"
    local title="Bookmark"
    local body
    case "$action" in
        added)
            body="<span color='#a6e3a1'>[ADDED]</span> $entry"
            ;;
        removed)
            body="<span color='#f38ba8'>[REMOVED]</span> $entry"
            ;;
    esac
    notify-send -a "$app" -i "$icon" "$title" "$body"
}

toggle_bookmark() {
    local entry="$1"
    [[ -z "$entry" ]] && return

    if [[ ${bookmarks_set["$entry"]+x} ]]; then
        local tmp
        tmp=$(mktemp)
        grep -Fxv -- "$entry" "$BOOKMARKS_FILE" > "$tmp" || true
        mv "$tmp" "$BOOKMARKS_FILE"
        unset 'bookmarks_set[$entry]'
        notify_bookmark "removed" "$entry"
    else
        local tmp
        tmp=$(mktemp)
        {
            printf '%s\n' "$entry"
            grep -Fxv -- "$entry" "$BOOKMARKS_FILE" 2>/dev/null || true
        } >> "$tmp"
        mv "$tmp" "$BOOKMARKS_FILE"
        bookmarks_set["$entry"]=1
        notify_bookmark "added" "$entry"
    fi
}

read_bookmarks
index_bookmarks
read_history
choice=$(show_rofi)
result=$?
choice=${choice%%$'\n'}

case "$result" in
    0)
        ;;
    10)
        [[ -n "$choice" ]] && toggle_bookmark "$choice"
        exit 0
        ;;
    *)
        exit 0
        ;;
esac

[[ -z "$choice" ]] && exit 0

if [[ "$choice" =~ ^https?:// ]]; then
    target="$choice"
elif [[ "$choice" =~ ^www\. ]]; then
    target="https://$choice"
elif [[ "$choice" =~ ^([A-Za-z0-9-]+\.)+[A-Za-z]{2,}(/[^[:space:]]*)?$ ]]; then
    target="https://$choice"
else
    encoded=$(urlencode "$choice")
    target="${SEARCH_BASE_URL}${encoded}"
fi

store_history "$choice"
xdg-open "$target" >/dev/null 2>&1 &
exit 0
