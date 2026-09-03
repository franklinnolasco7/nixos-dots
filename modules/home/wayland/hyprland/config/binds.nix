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

  directions = [
    "left"
    "right"
    "up"
    "down"
  ];

  mkDirectionalBinds =
    {
      prefix ? null,
      dispatch,
      opts ? [ ],
    }:
    map (
      dir: mkBind mainMod (if prefix == null then dir else "${prefix} + ${dir}") (dispatch dir) opts
    ) directions;

  resizeDeltas = {
    left = {
      x = -20;
      y = 0;
    };
    right = {
      x = 20;
      y = 0;
    };
    up = {
      x = 0;
      y = -20;
    };
    down = {
      x = 0;
      y = 20;
    };
  };

  resizeBinds = map (
    dir:
    let
      d = resizeDeltas.${dir};
    in
    mkBind mainMod "CTRL + ${dir}"
      "hl.dsp.window.resize({ x = ${toString d.x}, y = ${toString d.y}, relative = true })"
      [ { repeating = true; } ]
  ) directions;

  mediaKeys = [
    {
      key = "XF86AudioRaiseVolume";
      cmd = ''"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86AudioLowerVolume";
      cmd = ''"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86AudioMute";
      cmd = ''"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86AudioMicMute";
      cmd = ''"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86MonBrightnessUp";
      cmd = ''"brightnessctl -e4 -n2 set 5%+"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86MonBrightnessDown";
      cmd = ''"brightnessctl -e4 -n2 set 5%-"'';
      opts = [
        {
          locked = true;
          repeating = true;
        }
      ];
    }
    {
      key = "XF86AudioNext";
      cmd = ''"playerctl next"'';
      opts = [ { locked = true; } ];
    }
    {
      key = "XF86AudioPause";
      cmd = ''"playerctl play-pause"'';
      opts = [ { locked = true; } ];
    }
    {
      key = "XF86AudioPlay";
      cmd = ''"playerctl play-pause"'';
      opts = [ { locked = true; } ];
    }
    {
      key = "XF86AudioPrev";
      cmd = ''"playerctl previous"'';
      opts = [ { locked = true; } ];
    }
  ];

  mediaBinds = map (m: mkExecPlain m.key m.cmd m.opts) mediaKeys;

  screenshotDir = ''os.getenv("HOME") .. "/Pictures/Screenshots"'';

  screenshotBinds = [
    (mkBindPlain "Print" ''hl.dsp.exec_cmd("hyprshot -m output -z -o " .. ${screenshotDir})'' [ ])
    (mkBind mainMod "SHIFT + S" ''hl.dsp.exec_cmd("hyprshot -m region -z -o " .. ${screenshotDir})''
      [ ]
    )
    (mkBindPlain "CTRL + Print" ''hl.dsp.exec_cmd("hyprshot -m window -z -o " .. ${screenshotDir})''
      [ ]
    )
    (mkBindPlain "SHIFT + Print" ''
      hl.dsp.exec_cmd("hyprshot -m active -m window -z -o " .. ${screenshotDir})
    '' [ ])
  ];

  zoomBinds = [
    (mkBind mainMod "Z" "zoom" [ ])
    (mkBind mainMod "equal" "function() zoom(1.1) end" [ { repeating = true; } ])
    (mkBind mainMod "minus" "function() zoom(0.9) end" [ { repeating = true; } ])
    (mkBind mainMod "KP_ADD" "function() zoom(1.1) end" [ { repeating = true; } ])
    (mkBind mainMod "KP_SUBTRACT" "function() zoom(0.9) end" [ { repeating = true; } ])
  ];
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

    bind = [
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

      (mkBind mainMod "C" "hl.dsp.window.close()" [ ])
      (mkBind mainMod "M" "hl.dsp.exit()" [ ])
      (mkBind mainMod "SHIFT + F" "hl.dsp.window.fullscreen()" [ ])
      (mkBind mainMod "T" "hl.dsp.window.float({ action = \"toggle\" })" [ ])
      (mkBind mainMod "J" "hl.dsp.layout(\"togglesplit\")" [ ])

      (mkBind mainMod "SPACE" "hl.dsp.window.cycle_next()" [ ])
    ]
    ++ mkDirectionalBinds {
      dispatch = dir: "hl.dsp.focus({ direction = \"${dir}\" })";
    }
    ++ resizeBinds
    ++ mkDirectionalBinds {
      prefix = "SHIFT";
      dispatch = dir: "hl.dsp.window.swap({ direction = \"${dir}\" })";
    }
    ++ mkDirectionalBinds {
      prefix = "ALT";
      dispatch = dir: "hl.dsp.window.move({ direction = \"${dir}\" })";
    }
    ++ workspaceBinds
    ++ numpadBinds
    ++ [
      (mkBindPlain "ALT + D" "hl.dsp.focus({ workspace = \"previous\" })" [ ])
      (mkBindPlain "ALT + S" "hl.dsp.focus({ workspace = \"e+1\" })" [ ])
      (mkBindPlain "ALT + A" "hl.dsp.focus({ workspace = \"e-1\" })" [ ])

      (mkBind mainMod "mouse:275" "hl.dsp.focus({ workspace = \"e+1\" })" [ { mouse = true; } ])
      (mkBind mainMod "mouse:276" "hl.dsp.focus({ workspace = \"e-1\" })" [ { mouse = true; } ])

      (mkBind mainMod "mouse:272" "hl.dsp.window.drag()" [ { mouse = true; } ])
      (mkBind mainMod "mouse:273" "hl.dsp.window.resize()" [ { mouse = true; } ])

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

      (mkBindPlain "ALT + TAB" "hl.dsp.workspace.toggle_special(\"obsidian\")" [ ])
    ]
    ++ screenshotBinds
    ++ [
      (mkExec mainMod "F10" ''"gsr toggle"'' [ ])
      (mkExec mainMod "F9" ''"gsr save"'' [ ])
      (mkExec mainMod "F1" ''"toggle-resolution"'' [ ])
    ]
    ++ zoomBinds
    ++ mediaBinds;
  };
}
