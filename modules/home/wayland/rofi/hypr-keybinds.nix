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
    local chunk = f:read("*a")
    f:close()

    -- Lua < 5.3 can't parse `\u{XXXX}` escapes; Hyprland configs target 5.3+.
    -- Expand them to UTF-8 bytes so extraction works on any Lua (5.1+).
    local unpack = table.unpack or unpack
    chunk = chunk:gsub("\\u{(%x+)}", function(hex)
      local cp = tonumber(hex, 16)
      local b = {}
      if cp < 0x80 then
        b[1] = cp
      elseif cp < 0x800 then
        b[1] = 0xC0 + math.floor(cp / 0x40)
        b[2] = 0x80 + cp % 0x40
      elseif cp < 0x10000 then
        b[1] = 0xE0 + math.floor(cp / 0x1000)
        b[2] = 0x80 + math.floor(cp / 0x40) % 0x40
        b[3] = 0x80 + cp % 0x40
      else
        b[1] = 0xF0 + math.floor(cp / 0x40000)
        b[2] = 0x80 + math.floor(cp / 0x1000) % 0x40
        b[3] = 0x80 + math.floor(cp / 0x40) % 0x40
        b[4] = 0x80 + cp % 0x40
      end
      return string.char(unpack(b))
    end)

    local loaded = assert(load(chunk, config_path))
    loaded()
  '';
in
{
  home.packages = [
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
        modifier=''${modifier// /}
        modifier=''${modifier//+/ + }
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
  ];
}
