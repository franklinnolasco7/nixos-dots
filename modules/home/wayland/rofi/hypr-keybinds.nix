{ pkgs, ... }:

let
  hyprKeybindsLua = pkgs.writeScript "hypr-keybinds.lua" ''
    #!/usr/bin/env lua
    local config_path = arg[1] or (os.getenv("HOME") .. "/.config/hypr/hyprland.lua")

    local function dir_short(d)
      local map = { left = "l", right = "r", up = "u", down = "d" }
      return map[d] or d
    end

    local function ws_arg(w)
      return type(w) == "number" and tostring(w) or (w or "")
    end

    local config_lines
    local function comment_before(line)
      if not config_lines then
        config_lines = {}
        for l in io.lines(config_path) do
          config_lines[#config_lines + 1] = l
        end
      end
      for i = math.min(line - 1, #config_lines), 1, -1 do
        local c = config_lines[i]:match("^%s*%-%-%s*(.*)%s*$") or ""
        c = c:gsub("^[-=]+%s*", ""):gsub("%s*[-=]+$", "")
        if c ~= "" then
          return c
        end
      end
      return ""
    end

    local function ret(dispatcher, arg)
      return { __dispatcher = dispatcher, __arg = arg or "" }
    end

    local function serialize_args(args)
      if type(args) == "table" then
        local parts = {}
        for k, v in pairs(args) do
          parts[#parts + 1] = k .. "=" .. tostring(v)
        end
        return table.concat(parts, ",")
      elseif args ~= nil then
        return tostring(args)
      end
      return ""
    end

    local function make_callable(name)
      return setmetatable({}, {
        __call = function(self, args)
          return { __dispatcher = name, __arg = serialize_args(args) }
        end
      })
    end

    local mt = {
      __index = function(_, name)
        return make_callable(name)
      end,
    }

    hl = {}
    hl.dsp = setmetatable({
      exec_cmd = function(a) return ret("exec", tostring(a)) end,
      exit     = function() return ret("exit") end,
      layout   = function() return ret("togglesplit") end,
      focus    = function(a)
        if type(a) == "table" and a.direction then
          return ret("movefocus", dir_short(a.direction))
        end
        return ret("workspace", ws_arg(a and a.workspace))
      end,
      window = setmetatable({
        close      = function() return ret("killactive") end,
        fullscreen = function() return ret("fullscreen") end,
        float      = function() return ret("togglefloating") end,
        swap       = function(a) return ret("swapwindow", dir_short(a and a.direction)) end,
        move       = function(a)
          if a and a.direction then return ret("movewindow", dir_short(a.direction)) end
          return ret("movetoworkspace", ws_arg(a and a.workspace))
        end,
        drag       = function() return ret("movewindow", "mousemove") end,
        resize     = function() return ret("resizewindow", "mousemove") end,
      }, mt),
    }, mt)

    local function noop() end
    hl.monitor, hl.config, hl.env, hl.gesture, hl.on = noop, noop, noop, noop, noop
    hl.exec_cmd, hl.animation, hl.curve, hl.device, hl.window_rule = noop, noop, noop, noop, noop
    hl.get_workspace, hl.get_active_workspace, hl.get_active_window, hl.dispatch = noop, noop, noop, noop

    hl.bind = function(mods_key, dispatcher, opts)
      opts = opts or {}
      local parts = {}
      for token in mods_key:gmatch("[^+%s]+") do
        parts[#parts + 1] = token
      end
      local key = table.remove(parts)
      local mods = table.concat(parts, " + ")

      local flags = {}
      if opts.mouse then flags[#flags + 1] = "mouse" end
      if opts.locked then flags[#flags + 1] = "locked" end
      if opts.repeating then flags[#flags + 1] = "repeat" end
      flags = table.concat(flags, ",")

      if type(dispatcher) ~= "table" then
        local info = debug.getinfo(dispatcher, "S")
        print(("%s\t%s\tmacro\t%s\t%s"):format(mods, key, comment_before(info and info.linedefined or 0), flags))
        return
      end

      print(("%s\t%s\t%s\t%s\t%s"):format(mods, key, dispatcher.__dispatcher, dispatcher.__arg or "", flags))
    end

    local f = io.open(config_path, "r")
    if not f then
      io.stderr:write("hypr-keybinds.lua: cannot read " .. config_path .. "\n")
      os.exit(1)
    end
    local chunk = f:read("*a")
    f:close()

    local unpack = table.unpack or unpack
    chunk = chunk:gsub("\\u{(%x+)}", function(hex)
      local cp = tonumber(hex, 16)
      if cp < 0x80 then
        return string.char(cp)
      end
      local n = cp < 0x800 and 2 or (cp < 0x10000 and 3 or 4)
      local lead = ({ [2] = 0xC0, [3] = 0xE0, [4] = 0xF0 })[n]
      local bytes = {}
      for i = n, 2, -1 do
        bytes[i] = 0x80 + cp % 0x40
        cp = math.floor(cp / 0x40)
      end
      bytes[1] = lead + cp
      return string.char(unpack(bytes))
    end)

    assert(load(chunk, config_path))()
  '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "hypr-keybinds" ''
      CACHE_FILE="''${XDG_RUNTIME_DIR:-/tmp}/hypr_keybinds_cache"
      CACHE_TIMEOUT=3600

      normalize_modifiers() {
        local m="$1"
        m=''${m//SUPER/󰘳}
        m=''${m//SHIFT/Shift}
        m=''${m//CTRL/Ctrl}
        m=''${m//Control/Ctrl}
        m=''${m//ALT/Alt}
        m=''${m//ISO_Left_Tab/Shift+Tab}
        m=''${m//[[:space:]]/}

        echo "$m" | awk -F'+' '{
          out=""
          for(i=1;i<=NF;i++) {
            if(length($i)==1) $i=toupper($i)
            if(out!="") out=out" + "
            out=out$i
          }
          print out
        }'
      }

      format_display() {
        local modifier="$1" key="$2" action="$3" note="$4" prefix="$5" data="''${6:-$3|$4}"
        local normalized label note_display body

        normalized=$(normalize_modifiers "$modifier")
        label="''${normalized:+$normalized + }$key"
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

      truncate_text() {
        local text="$1" max=''${2:-64}
        if [[ -n $text && ''${#text} -gt $max ]]; then
          echo "''${text:0:$((max - 3))}..."
        else
          echo "$text"
        fi
      }

      collect_bindings_from_lua() {
        local source="$1"
        [[ -r $source ]] || return
        command -v lua >/dev/null 2>&1 || return

        lua ${hyprKeybindsLua} "$source" \
          | while IFS=$'\t' read -r modifier key action arg flags; do
            [[ -z $action ]] && continue
            local note="$arg"
            [[ -n $flags ]] && note="$note [''${flags}]"
            format_display "$modifier" "$key" "$action" "$note" "" "$action|$arg"
          done
      }

      collect_bindings_from_rofi() {
        local rasi="$HOME/.config/rofi/config.rasi"
        if [[ -r $rasi ]]; then
          grep -E '^kb-mode-' "$rasi" 2>/dev/null | while IFS= read -r line; do
            local key=''${line%%:*}
            key=''${key## }
            key=''${key%% }
            local value=''${line#*:}
            value=''${value# }
            value=''${value%;}
            value=''${value%\"}
            value=''${value#\"}
            [[ -z $value ]] && continue
            combo=''${value#*,}
            combo=''${combo## }
            combo=''${combo%% }
            [[ -z $combo ]] && continue
            combo=''${combo//ISO_Left_Tab/Shift + Tab}
            local kb_mod=''${combo%+*} kb_key=''${combo##*+}
            kb_mod=''${kb_mod// /}
            kb_key=''${kb_key// /}
            format_display "$kb_mod" "$kb_key" "rofi → $label" "$key" ""
          done
        fi

        local nixos_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/../nixos-dots/modules"
        [[ -d $nixos_dir ]] || nixos_dir="$HOME/nixos-dots/modules"
        [[ -d $nixos_dir ]] || return
        grep -rhn '\-kb-' "$nixos_dir" 2>/dev/null \
          | grep -v 'hypr-keybinds.nix' \
          | grep -oE '\-kb-[a-z0-9-]+[[:space:]]+"[^"]*"' \
          | while IFS= read -r match; do
            local key=''${match%%[[:space:]]*}
            key=''${key#-}
            local value=''${match#*[[:space:]]}
            value=''${value#\"}
            value=''${value%\"}
            [[ -z $value ]] && continue
            if [[ $value == '$'* ]]; then
              case $value in
                '$BOOKMARK_KEY') value="Control+f"; key="kb-bookmark" ;;
                *) continue ;;
              esac
            fi
            local label=''${key#kb-}
            IFS=',' read -ra combos <<< "$value"
            for combo in "''${combos[@]}"; do
              combo=''${combo## }
              combo=''${combo%% }
              [[ -z $combo ]] && continue
              combo=$(normalize_modifiers "$combo")
              local kb_mod=''${combo% + *} kb_key=''${combo##* + }
              format_display "$kb_mod" "$kb_key" "rofi → $label" "$key" ""
            done
          done
      }

      cache_fresh=false
      if [[ -f $CACHE_FILE ]]; then
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
        [[ $cache_age -lt $CACHE_TIMEOUT ]] && cache_fresh=true
      fi

      if [[ $cache_fresh == false ]] || [[ $1 == "--rebuild" ]]; then
        {
          collect_bindings_from_lua "$HOME/.config/hypr/hyprland.lua"
          collect_bindings_from_rofi
        } >"$CACHE_FILE"
      fi

      mapfile -t lines <"$CACHE_FILE"

      [[ ''${#lines[@]} -eq 0 ]] && {
        notify-send "Keybinds" "No bindings found"
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
          -mesg "<span size='large'><b>Keybinds</b></span>")

      [[ -z $result ]] && exit 0

      read -r index _ <<<"$result"
      action_data="''${lines[$index]##*$'\t'}"

      IFS='|' read -r action param <<<"$action_data"

      if [[ $action == "exec" ]]; then
        eval "$param" &
      elif [[ $action == "rofi"* ]]; then
        :
      elif [[ $action == "macro" || -z $action ]]; then
        :
      else
        [[ -n $param ]] && hyprctl dispatch "$action" "$param" || hyprctl dispatch "$action"
      fi
    '')
  ];
}
