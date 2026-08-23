{ lib, ... }:

let
  inherit (lib) mkLuaInline;

  mainMod = "SUPER";
  terminal = "kitty";
  fileManager = "thunar";
  web_search = "rofi-web-search";

  mkBind = mods: key: luaExpr: opts: {
    _args = [
      "${mods} + ${key}"
      (mkLuaInline luaExpr)
    ]
    ++ opts;
  };

  mkBindPlain = key: luaExpr: opts: {
    _args = [
      key
      (mkLuaInline luaExpr)
    ]
    ++ opts;
  };

  mkExec =
    mods: key: luaString: opts:
    mkBind mods key "hl.dsp.exec_cmd(${luaString})" opts;

  mkExecPlain =
    key: luaString: opts:
    mkBindPlain key "hl.dsp.exec_cmd(${luaString})" opts;

  workspaceBinds = lib.concatLists (
    lib.genList (
      i:
      let
        ws = i + 1;
        # Lua's `i % 10` renders the 10th workspace as key 0
        key = if ws == 10 then "0" else toString ws;
      in
      [
        (mkBind mainMod key "hl.dsp.focus({ workspace = ${toString ws} })" [ ])
        (mkBind mainMod "SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString ws} })" [ ])
      ]
    ) 10
  );

  numpadKeys = [
    "KP_End"
    "KP_Down"
    "KP_Next"
    "KP_Left"
    "KP_Begin"
    "KP_Right"
    "KP_Home"
    "KP_Up"
    "KP_Prior"
    "KP_Insert"
  ];

  numpadBinds = lib.concatLists (
    lib.imap1 (i: key: [
      (mkBind mainMod key "hl.dsp.focus({ workspace = ${toString i} })" [ ])
      (mkBind mainMod "SHIFT + ${key}" "hl.dsp.window.move({ workspace = ${toString i} })" [ ])
    ]) numpadKeys
  );
in
{
  wayland.windowManager.hyprland.settings = {
    zoom = {
      _var = mkLuaInline ''
        function(mult)
          local z = hl.get_config("cursor.zoom_factor")
          local nz
          if mult ~= nil then
            nz = z * mult
          else
            nz = (z ~= 1) and 1 or 1.5
          end
          nz = math.max(1, math.min(3, nz))
          hl.config({ cursor = { zoom_factor = nz } })
        end
      '';
    };

    bind =
      # --- Applications ---
      [
        (mkExec mainMod "Return" ''"${terminal}"'' [ ])
        (mkExec mainMod "B" ''"firefox"'' [ ])
        (mkExec mainMod "E" ''"${fileManager}"'' [ ])
        (mkExec mainMod "D" ''"rofi -show drun"'' [ ])
        (mkExec mainMod "R" ''"rofi -show run -run-command 'kitty -e fish -c \"{cmd}; read\"'"'' [ ])
        (mkExec mainMod "S" ''"rofi -show ssh"'' [ ])
        (mkExec mainMod "TAB" ''"rofi -show window"'' [ ])
        (mkExec mainMod "W" ''"${web_search}"'' [ ])
        (mkExec mainMod "N" ''"swaync-client -t -sw"'' [ ])
        (mkExec mainMod "SHIFT + W" ''"wallpaper"'' [ ])

        # --- Window Management ---
        (mkBind mainMod "C" "hl.dsp.window.close()" [ ])
        (mkBind mainMod "M" "hl.dsp.exit()" [ ])
        (mkBind mainMod "SHIFT + F" "hl.dsp.window.fullscreen()" [ ])
        (mkBind mainMod "T" "hl.dsp.window.float({ action = \"toggle\" })" [ ])
        (mkBind mainMod "J" "hl.dsp.layout(\"togglesplit\")" [ ])

        # --- Focus Movement ---
        (mkBind mainMod "left" "hl.dsp.focus({ direction = \"left\" })" [ ])
        (mkBind mainMod "right" "hl.dsp.focus({ direction = \"right\" })" [ ])
        (mkBind mainMod "up" "hl.dsp.focus({ direction = \"up\" })" [ ])
        (mkBind mainMod "down" "hl.dsp.focus({ direction = \"down\" })" [ ])

        # --- Cycle All Windows ---
        (mkBind mainMod "SPACE" "hl.dsp.window.cycle_next()" [ ])

        # --- Resize Window ---
        (mkBind mainMod "CTRL + left" "hl.dsp.window.resize({ x = -20, y = 0, relative = true })" [
          { repeating = true; }
        ])
        (mkBind mainMod "CTRL + right" "hl.dsp.window.resize({ x = 20, y = 0, relative = true })" [
          { repeating = true; }
        ])
        (mkBind mainMod "CTRL + up" "hl.dsp.window.resize({ x = 0, y = -20, relative = true })" [
          { repeating = true; }
        ])
        (mkBind mainMod "CTRL + down" "hl.dsp.window.resize({ x = 0, y = 20, relative = true })" [
          { repeating = true; }
        ])

        # --- Move Window in direction ---
        (mkBind mainMod "SHIFT + left" "hl.dsp.window.swap({ direction = \"left\" })" [ ])
        (mkBind mainMod "SHIFT + right" "hl.dsp.window.swap({ direction = \"right\" })" [ ])
        (mkBind mainMod "SHIFT + up" "hl.dsp.window.swap({ direction = \"up\" })" [ ])
        (mkBind mainMod "SHIFT + down" "hl.dsp.window.swap({ direction = \"down\" })" [ ])

        # --- Move Floating Window ---
        (mkBind mainMod "ALT + left" "hl.dsp.window.move({ direction = \"left\" })" [ ])
        (mkBind mainMod "ALT + right" "hl.dsp.window.move({ direction = \"right\" })" [ ])
        (mkBind mainMod "ALT + up" "hl.dsp.window.move({ direction = \"up\" })" [ ])
        (mkBind mainMod "ALT + down" "hl.dsp.window.move({ direction = \"down\" })" [ ])
      ]
      ++ workspaceBinds
      ++ numpadBinds
      ++ [
        # --- Workspace Navigation ---
        (mkBindPlain "ALT + D" "hl.dsp.focus({ workspace = \"previous\" })" [ ])
        (mkBindPlain "ALT + S" "hl.dsp.focus({ workspace = \"e+1\" })" [ ])
        (mkBindPlain "ALT + A" "hl.dsp.focus({ workspace = \"e-1\" })" [ ])

        # --- Mouse Workspace Switching ---
        (mkBind mainMod "mouse:275" "hl.dsp.focus({ workspace = \"e+1\" })" [ { mouse = true; } ])
        (mkBind mainMod "mouse:276" "hl.dsp.focus({ workspace = \"e-1\" })" [ { mouse = true; } ])

        # --- Mouse Actions ---
        (mkBind mainMod "mouse:272" "hl.dsp.window.drag()" [ { mouse = true; } ])
        (mkBind mainMod "mouse:273" "hl.dsp.window.resize()" [ { mouse = true; } ])

        # --- Utilities ---
        (mkExec mainMod "V" ''
          "rofi -dmenu -display-columns 2 -p '\u{F0EA}' -show-icons -theme-str 'listview { columns: 1; }'"
            .. " < <(cliphist-rofi-img)"
            .. " | xargs -I {} cliphist-rofi-img {}"
        '' [ ])
        (mkExec mainMod "PERIOD" ''
          "rofimoji --selector rofi --action clipboard --prompt '\u{F0785}'"
            .. " --selector-args='-no-show-icons'"
        '' [ ])
        (mkExec mainMod "I" ''"hypr-keybinds"'' [ ])
        (mkExec mainMod "L" ''"hyprlock"'' [ ])
        (mkExec mainMod "CTRL + F12" ''"toggle-laptop-kb"'' [ ])
        (mkExec mainMod "CTRL + F11" ''"toggle-laptop-tp"'' [ ])
        (mkExec mainMod "SHIFT + C" ''"hyprpicker -a"'' [ ])

        # --- Minimize ---
        (mkBind mainMod "X" ''
          function()
            if hl.get_workspace("special:minimized") then
              hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
              hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
            else
              hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
              hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
            end
          end
        '' [ ])

        # --- Screenshots ---
        (mkBindPlain "Print" ''
          hl.dsp.exec_cmd("hyprshot -m output -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots")
        '' [ ])
        (mkBind mainMod "SHIFT + S" ''
          hl.dsp.exec_cmd("hyprshot -m region -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots")
        '' [ ])
        (mkBindPlain "CTRL + Print" ''
          hl.dsp.exec_cmd("hyprshot -m window -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots")
        '' [ ])
        (mkBindPlain "SHIFT + Print" ''
          hl.dsp.exec_cmd("hyprshot -m active -m window -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots")
        '' [ ])

        # --- Recording ---
        (mkExec mainMod "F10" ''"gsr toggle"'' [ ])
        (mkExec mainMod "F9" ''"gsr save"'' [ ])

        # --- Zoom ---
        (mkBind mainMod "Z" "zoom" [ ])
        (mkBind mainMod "equal" "function() zoom(1.1) end" [ { repeating = true; } ])
        (mkBind mainMod "minus" "function() zoom(0.9) end" [ { repeating = true; } ])
        (mkBind mainMod "KP_ADD" "function() zoom(1.1) end" [ { repeating = true; } ])
        (mkBind mainMod "KP_SUBTRACT" "function() zoom(0.9) end" [ { repeating = true; } ])

        # --- Media Keys ---
        (mkExecPlain "XF86AudioRaiseVolume" ''"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86AudioLowerVolume" ''"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86AudioMute" ''"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86AudioMicMute" ''"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86MonBrightnessUp" ''"brightnessctl -e4 -n2 set 5%+"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86MonBrightnessDown" ''"brightnessctl -e4 -n2 set 5%-"'' [
          {
            locked = true;
            repeating = true;
          }
        ])
        (mkExecPlain "XF86AudioNext" ''"playerctl next"'' [ { locked = true; } ])
        (mkExecPlain "XF86AudioPause" ''"playerctl play-pause"'' [ { locked = true; } ])
        (mkExecPlain "XF86AudioPlay" ''"playerctl play-pause"'' [ { locked = true; } ])
        (mkExecPlain "XF86AudioPrev" ''"playerctl previous"'' [ { locked = true; } ])
      ];
  };
}
