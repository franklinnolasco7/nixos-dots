{ pkgs, ... }:

let
  hyprKeybindsLua = pkgs.writeScript "hypr-keybinds.lua" ''
    #!/usr/bin/env lua
    -- hypr-keybinds.lua -- extract keybinds from Hyprland 0.55+ Lua config.
    --
    -- Evaluates hyprland.lua with a stub `hl` table that records binds.
    -- Loops (e.g. workspace binds) execute naturally; string concat resolves.
    -- Prints TSV rows: mods<TAB>key<TAB>dispatcher<TAB>arg<TAB>flags
    --
    -- Usage: lua hypr-keybinds.lua [path-to-hyprland.lua]

    local config_path = arg[1] or (os.getenv("HOME") .. "/.config/hypr/hyprland.lua")

    local function dir_short(d)
      local map = { left = "l", right = "r", up = "u", down = "d" }
      return map[d] or d
    end

    local function ws_arg(w)
      if type(w) == "number" then
        return tostring(w)
      end
      return w or ""
    end

    local function comment_before(line)
      local f = io.open(config_path, "r")
      if not f then
        return ""
      end
      local lines = {}
      for l in f:lines() do
        lines[#lines + 1] = l
      end
      f:close()
      for i = math.min(line - 1, #lines), 1, -1 do
        local c = lines[i]:match("^%s*%-%-%s*(.*)%s*$") or ""
        c = c:gsub("^[-=]+%s*", ""):gsub("%s*[-=]+$", "")
        if c ~= "" then
          return c
        end
      end
      return ""
    end

    local function dsp_ret(dispatcher, arg)
      return { __dispatcher = dispatcher, __arg = arg or "" }
    end

    hl = {} -- global: dofile'd config chunk needs to see it
    hl.dsp = {}

    -- register(path, fn) where fn(arg) returns dsp_ret; path may be dotted (window.close)
    local function register(path, fn)
      local obj = hl.dsp
      local parts = {}
      for part in path:gmatch("[^.]+") do
        parts[#parts + 1] = part
      end
      local name = table.remove(parts)
      for _, p in ipairs(parts) do
        obj[p] = obj[p] or {}
        obj = obj[p]
      end
      obj[name] = function(...)
        return fn(select(1, ...))
      end
    end

    register("exec_cmd", function(a)
      return dsp_ret("exec", tostring(a))
    end)
    register("exit", function()
      return dsp_ret("exit")
    end)
    register("window.close", function()
      return dsp_ret("killactive")
    end)
    register("window.fullscreen", function()
      return dsp_ret("fullscreen")
    end)
    register("window.float", function()
      return dsp_ret("togglefloating")
    end)
    register("window.swap", function(a)
      return dsp_ret("swapwindow", dir_short(a and a.direction))
    end)
    register("window.move", function(a)
      return dsp_ret("movetoworkspace", ws_arg(a and a.workspace))
    end)
    register("window.drag", function()
      return dsp_ret("movewindow", "mousemove")
    end)
    register("window.resize", function()
      return dsp_ret("resizewindow", "mousemove")
    end)
    register("layout", function()
      return dsp_ret("togglesplit")
    end)
    register("focus", function(a)
      if type(a) == "table" and a.direction then
        return dsp_ret("movefocus", dir_short(a.direction))
      end
      return dsp_ret("workspace", ws_arg(a and a.workspace))
    end)

    -- unknown dsp paths degrade to display-only rows (skipped on execute)
    local dsp_mt = {
      __index = function(_, name)
        return function(...)
          return dsp_ret("__" .. name)
        end
      end,
    }
    setmetatable(hl.dsp, dsp_mt)

    local function noop() end

    hl.monitor = noop
    hl.config = noop
    hl.env = noop
    hl.gesture = noop
    hl.on = noop
    hl.exec_cmd = noop
    hl.animation = noop
    hl.curve = noop
    hl.device = noop
    hl.window_rule = noop

    hl.bind = function(mods_key, dispatcher, opts)
      opts = opts or {}
      local parts = {}
      for raw_token in mods_key:gmatch("[^+]+") do
        local token = raw_token:gsub("^%s+", ""):gsub("%s+$", "")
        if token ~= "" then
          parts[#parts + 1] = token
        end
      end
      local key = table.remove(parts)
      local mods = table.concat(parts, " + ")

      local flags = {}
      if opts.mouse then
        flags[#flags + 1] = "mouse"
      end
      if opts.locked then
        flags[#flags + 1] = "locked"
      end
      if opts.repeating then
        flags[#flags + 1] = "repeat"
      end

      if type(dispatcher) ~= "table" then
        local info = debug.getinfo(dispatcher, "S")
        local line = info and info.linedefined or 0
        print(mods .. "\t" .. key .. "\tmacro\t" .. comment_before(line) .. "\t" .. table.concat(flags, ","))
        return
      end
      local d = dispatcher.__dispatcher
      local a = dispatcher.__arg or ""

      print(mods .. "\t" .. key .. "\t" .. d .. "\t" .. a .. "\t" .. table.concat(flags, ","))
    end

    local f = io.open(config_path, "r")
    if not f then
      io.stderr:write("hypr-keybinds.lua: cannot read " .. config_path .. "\n")
      os.exit(1)
    end
    f:close()

    dofile(config_path)
  '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "cliphist-rofi-img" ''
            tmp_dir="/tmp/cliphist"
            rm -rf "$tmp_dir"

            if [[ -n $1 ]]; then
              shopt -s nullglob
              image_files=("$tmp_dir/$1".*)
              if [[ ''${#image_files[@]} -gt 0 ]]; then
                imv "''${image_files[0]}" 2>/dev/null &
              fi
              cliphist decode <<<"$1" | wl-copy
              exit
            fi

            mkdir -p "$tmp_dir"

            read -r -d ''' prog <<EOF
      /^[0-9]+\s<meta http-equiv=/ { next }
      match(\$0, /^([0-9]+)\s(\[\[\s)?binary.*(jpg|jpeg|png|bmp)/, grp) {
          system("echo " grp[1] "\\\\\t | cliphist decode >$tmp_dir/"grp[1]"."grp[3])
          print \$0"\0icon\x1f$tmp_dir/"grp[1]"."grp[3]
          next
      }
      1
      EOF
            cliphist list | gawk "$prog"
    '')

    (pkgs.writeShellScriptBin "hypr-keybinds" ''
      CACHE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/hypr_keybinds_cache"
      CACHE_TIMEOUT=3600 # 1 hour in seconds

      CONFIG_SOURCES=(
        "$HOME/.config/hypr/hyprland.lua"
      )

      normalize_modifiers() {
        local modifier="$1"
        modifier=''${modifier//\$mainMod/󰘳}
        modifier=''${modifier//SUPER/󰘳}
        modifier=''${modifier//SHIFT/Shift}
        modifier=''${modifier//CTRL/Ctrl}
        modifier=''${modifier//Control/Ctrl}
        modifier=''${modifier//ALT/Alt}
        modifier=$(echo "$modifier" | sed 's/^ *//; s/ *$//; s/  */ /g')
        modifier=''${modifier// / + }
        echo "$modifier"
      }

      truncate_text() {
        local text="$1" max=''${2:-64}
        if [[ -n $text && ''${#text} -gt $max ]]; then
          echo "''${text:0:$((max - 3))}..."
        else
          echo "$text"
        fi
      }

      format_display() {
        local modifier="$1" key="$2" action="$3" note="$4" prefix="$5" data="''${6:-$3|$4}"
        local normalized label note_display body

        normalized=$(normalize_modifiers "$modifier")
        if [[ -n $normalized ]]; then
          label="$normalized + $key"
        else
          label="$key"
        fi

        note_display=$(truncate_text "$note")

        if [[ -n $note_display ]]; then
          body=$(printf "<b>%s</b>  <i>%s</i>  <span color='gray'>%s</span>" "$label" "$action" "$note_display")
        else
          body=$(printf "<b>%s</b>  <i>%s</i>" "$label" "$action")
        fi

        if [[ -n $prefix ]]; then
          printf "%s\t%s\t%s\n" "$prefix" "$body" "$data"
        else
          printf "\t%s\t%s\n" "$body" "$data"
        fi
      }

      collect_bindings_from_lua() {
        local source="$1"
        [[ -r $source ]] || return
        command -v lua >/dev/null 2>&1 || return

        lua ${hyprKeybindsLua} "$source" \
          | while IFS=$'\t' read -r modifier key action arg flags; do
            [[ -z $action || $action == "__"* ]] && continue
            local note="$arg"
            [[ -n $flags ]] && note="$note [''${flags}]"
            format_display "$modifier" "$key" "$action" "$note" "" "$action|$arg"
          done
      }

      cache_fresh=false
      if [[ -f $CACHE_FILE ]]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        [[ $cache_age -lt $CACHE_TIMEOUT ]] && cache_fresh=true
      fi

      if [[ $cache_fresh == false ]] || [[ $1 == "--rebuild" ]]; then
        {
          for source in "''${CONFIG_SOURCES[@]}"; do
            collect_bindings_from_lua "$source"
          done

          for mode in next previous; do
            mapfile -t combos < <(sed -n "s/.*kb-mode-''${mode}:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$HOME/.config/rofi/config.rasi" | tr ',' '\n')
            for combo in "''${combos[@]}"; do
              [[ -z $combo ]] && continue
              kb_mod="''${combo%%+*}" kb_key="''${combo#*+}"
              kb_mod=$(echo "$kb_mod" | sed 's/^ *//; s/ *$//')
              kb_key=$(echo "$kb_key" | sed 's/^ *//; s/ *$//')
              format_display "$kb_mod" "$kb_key" "rofi → switch to ''${mode} mode" "config.rasi • kb-mode-''${mode}"
            done
          done
        } >"$CACHE_FILE"
      fi

      mapfile -t lines <"$CACHE_FILE"

      [[ ''${#lines[@]} -eq 0 ]] && {
        notify-send "Hypr keybinds" "No bindings found"
        exit 0
      }

      list_lines=''${#lines[@]}
      ((list_lines > 12)) && list_lines=12

      result=$(printf '%s\n' "''${lines[@]}" \
        | cut -f1,2 \
        | sed 's/\t/  /' \
        | rofi -dmenu -i -format 'i s' -markup-rows -p "󰌌" \
          -theme-str 'window { width: 820px; }' \
          -theme-str "listview { lines: ''${list_lines}; spacing: 6px; }" \
          -theme-str 'element-text { font: "JetBrainsMono Nerd Font Mono 12"; }' \
          -theme-str 'message { enabled: true; padding: 4px 16px; }' \
          -mesg "<span size='large'><b>Hyprland Keybinds</b></span>")

      [[ -z $result ]] && exit 0

      read -r index _ <<<"$result"
      action_data="''${lines[$index]##*$'\t'}"

      IFS='|' read -r action param <<<"$action_data"

      if [[ $action == "exec" ]]; then
        eval "$param" &
      elif [[ -n $action && $action != "rofi"* && $action != "macro"* ]]; then
        [[ -n $param ]] && hyprctl dispatch "$action" "$param" || hyprctl dispatch "$action"
      fi
    '')

    (pkgs.writeShellScriptBin "rofi-web-search" ''
      set -uo pipefail

      HISTORY_FILE="''${XDG_RUNTIME_DIR:-/tmp}/rofi-web-search-history"
      HISTORY_LIMIT=''${ROFI_WEB_SEARCH_HISTORY_LIMIT:-200}
      SEARCH_BASE_URL="''${ROFI_WEB_SEARCH_BASE:-https://duckduckgo.com/?q=}"
      ROFI_THEME_PATH="''${ROFI_WEB_SEARCH_THEME:-custom}"
      PROMPT_LABEL="''${ROFI_WEB_SEARCH_PROMPT:-}"

      BOOKMARKS_FILE="''${ROFI_WEB_SEARCH_BOOKMARKS:-''${XDG_DATA_HOME:-$HOME/.local/share}/rofi-web-search-bookmarks}"
      BOOKMARKS_LIMIT=''${ROFI_WEB_SEARCH_BOOKMARKS_LIMIT:-25}
      BOOKMARK_ICON="''${ROFI_WEB_SEARCH_BOOKMARK_ICON:-user-bookmarks-symbolic}"
      BOOKMARK_KEY="''${ROFI_WEB_SEARCH_BOOKMARK_KEY:-Control+f}"

      history=()
      bookmarks=()
      declare -A bookmarks_set=()

      mkdir -p "$(dirname "$HISTORY_FILE")"
      [[ -f $HISTORY_FILE ]] || : >"$HISTORY_FILE"
      mkdir -p "$(dirname "$BOOKMARKS_FILE")"
      [[ -f $BOOKMARKS_FILE ]] || : >"$BOOKMARKS_FILE"

      read_history() {
        mapfile -t history <"$HISTORY_FILE" 2>/dev/null || history=()
      }

      read_bookmarks() {
        mapfile -t bookmarks <"$BOOKMARKS_FILE" 2>/dev/null || bookmarks=()
      }

      index_bookmarks() {
        local key
        for key in "''${!bookmarks_set[@]}"; do
          unset 'bookmarks_set[$key]'
        done

        local bookmark
        for bookmark in "''${bookmarks[@]}"; do
          [[ -n $bookmark ]] && bookmarks_set["$bookmark"]=1
        done
      }

      show_rofi() {
        {
          declare -A seen=()

          if ((''${#bookmarks[@]})); then
            local bookmark
            for bookmark in "''${bookmarks[@]}"; do
              [[ -z $bookmark || ''${seen["$bookmark"]+x} ]] && continue
              seen["$bookmark"]=1
              printf '%s\x00icon\x1f%s\n' "$bookmark" "$BOOKMARK_ICON"
            done
          fi

          if ((''${#history[@]})); then
            local entry
            for entry in "''${history[@]}"; do
              [[ -z $entry || ''${seen["$entry"]+x} ]] && continue
              seen["$entry"]=1
              printf '%s\n' "$entry"
            done
          fi

          if ((''${#bookmarks[@]} == 0 && ''${#history[@]} == 0)); then
            printf '''
          fi
        } | rofi -dmenu -i -p "$PROMPT_LABEL" -theme "$ROFI_THEME_PATH" -show-icons -kb-custom-1 "$BOOKMARK_KEY" -kb-move-char-forward ""
      }

      urlencode() {
        local input="$1"
        local length=''${#input}
        local i char
        for ((i = 0; i < length; i++)); do
          char=''${input:i:1}
          case "$char" in
            [a-zA-Z0-9._~-])
              printf '%s' "$char"
              ;;
            ' ')
              printf '%s' '+'
              ;;
            *)
              printf '%%%02X' "${"'"}''${char}'"
              ;;
          esac
        done
      }

      store_history() {
        local entry="$1"
        if [[ ''${bookmarks_set["$entry"]+x} ]]; then
          return
        fi

        local tmp
        tmp=$(mktemp)

        printf '%s\n' "$entry" >"$tmp"
        if [[ -f $HISTORY_FILE ]]; then
          grep -Fxv "$entry" "$HISTORY_FILE" >>"$tmp" || true
        fi
        head -n "$HISTORY_LIMIT" "$tmp" >"$HISTORY_FILE"
        rm -f "$tmp"
      }

      notify_bookmark() {
        command -v notify-send >/dev/null 2>&1 || return 0
        local action="$1"
        local entry="$2"
        local app="''${ROFI_WEB_SEARCH_NOTIFY_APP:-Rofi Web Search}"
        local icon="''${ROFI_WEB_SEARCH_NOTIFY_ICON:-user-bookmarks-symbolic}"
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
        [[ -z $entry ]] && return

        if [[ ''${bookmarks_set["$entry"]+x} ]]; then
          local tmp
          tmp=$(mktemp)
          grep -Fxv -- "$entry" "$BOOKMARKS_FILE" >"$tmp" || true
          mv "$tmp" "$BOOKMARKS_FILE"
          unset 'bookmarks_set[$entry]'
          notify_bookmark "removed" "$entry"
        else
          local tmp
          tmp=$(mktemp)
          {
            printf '%s\n' "$entry"
            grep -Fxv -- "$entry" "$BOOKMARKS_FILE" 2>/dev/null || true
          } >>"$tmp"
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
      choice=''${choice%%$'\n'}

      case "$result" in
        0)
          ;;
        10)
          [[ -n $choice ]] && toggle_bookmark "$choice"
          exit 0
          ;;
        *)
          exit 0
          ;;
      esac

      [[ -z $choice ]] && exit 0

      if [[ $choice =~ ^https?:// ]]; then
        target="$choice"
      elif [[ $choice =~ ^www\. ]]; then
        target="https://$choice"
      elif [[ $choice =~ ^([A-Za-z0-9-]+\.)+[A-Za-z]{2,}(/[^[:space:]]*)?$ ]]; then
        target="https://$choice"
      else
        encoded=$(urlencode "$choice")
        target="''${SEARCH_BASE_URL}''${encoded}"
      fi

      store_history "$choice"
      xdg-open "$target" >/dev/null 2>&1 &
      exit 0
    '')

    (pkgs.writeShellScriptBin "wallpaper" ''
      set -uo pipefail

      WALLPAPER_DIR="$HOME/nixos-dots/themes/wallpapers"
      DRY_RUN=0
      case "''${1:-}" in
        --dry-run) DRY_RUN=1 ;;
        *) WALLPAPER_DIR="''${1:-$WALLPAPER_DIR}" ;;
      esac

      THUMBNAIL_DIR="$HOME/.cache/rofi-wallpaper"
      THUMBNAIL_SIZE="320x180"
      ROFI_THEME="$HOME/.config/rofi/theme-wallpaper.rasi"
      HISTORY_FILE="$THUMBNAIL_DIR/history"
      HISTORY_LIMIT="''${ROFI_WALLPAPER_HISTORY_LIMIT:-200}"

      TRANSITION_TYPE=grow
      TRANSITION_POS=center
      TRANSITION_DURATION=1
      TRANSITION_FPS=60

      declare -A WALLPAPERS=()

      mkdir -p "$THUMBNAIL_DIR"
      [[ -f $HISTORY_FILE ]] || : >"$HISTORY_FILE"

      warn() { printf 'wallpaper: %s\n' "$*" >&2; }

      wallpapers() {
        find "$WALLPAPER_DIR" -type f \( \
          -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
          -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \
          -o -iname '*.tiff' \) | sort
      }

      thumbnail_path() {
        printf '%s/%s.png' "$THUMBNAIL_DIR" "''${1//\//_}"
      }

      ensure_daemon() {
        pgrep -x awww-daemon >/dev/null || {
          awww-daemon &
          sleep 1
        }
      }

      ensure_thumbnail() {
        local img=$1 name=$2 thumb
        thumb="$(thumbnail_path "$name")"
        [[ -f $thumb ]] && return 0
        magick "$img" \
          -thumbnail "''${THUMBNAIL_SIZE}^" \
          -gravity center \
          -extent "$THUMBNAIL_SIZE" \
          "$thumb" 2>/dev/null \
          || warn "thumbnail failed for $name"
      }

      index_wallpapers() {
        local img rel name
        while IFS= read -r img; do
          rel="''${img#"$WALLPAPER_DIR/"}"
          name="''${rel%.*}"
          WALLPAPERS["$name"]="$img"
          ensure_thumbnail "$img" "$name"
        done < <(wallpapers)
      }

      read_history() {
        mapfile -t history <"$HISTORY_FILE" 2>/dev/null || history=()
      }

      store_history() {
        local name=$1 tmp
        [[ -n $name ]] || return 0
        tmp="$(mktemp)"
        printf '%s\n' "$name" >"$tmp"
        grep -Fxv -- "$name" "$HISTORY_FILE" >>"$tmp" 2>/dev/null || true
        head -n "$HISTORY_LIMIT" "$tmp" >"$HISTORY_FILE"
        rm -f "$tmp"
      }

      build_menu() {
        local name
        declare -A seen=()
        for name in "''${history[@]}"; do
          [[ -z $name || ''${seen["$name"]+x} || ! ''${WALLPAPERS["$name"]+x} ]] && continue
          seen["$name"]=1
          printf '%s\0icon\x1f%s\n' "$name" "$(thumbnail_path "$name")"
        done
        for name in "''${!WALLPAPERS[@]}"; do
          [[ ''${seen["$name"]+x} ]] && continue
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

      if [[ $DRY_RUN -eq 1 ]]; then
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

      if [[ -n $selection ]]; then
        apply_wallpaper "''${WALLPAPERS[$selection]}" && store_history "$selection"
      fi
    '')
  ];
}
