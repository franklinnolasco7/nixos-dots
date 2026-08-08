-- ============================================================================
--  HYPRLAND CONFIGURATION (Lua — Hyprland 0.55+)
--  Refer to: https://wiki.hypr.land/Configuring/Start/
-- ============================================================================

-- ============================================================================
--  MONITORS
-- ============================================================================
hl.monitor({
  output   = "eDP-1",
  mode     = "1920x1080@60",
  position = "0x0",
  scale    = 1,
})

-- ============================================================================
--  PROGRAMS
-- ============================================================================
local terminal   = "kitty"
local fileManager = "thunar"
local rofi_theme  = os.getenv("HOME") .. "/.config/rofi/config.rasi"
local web_search  = os.getenv("HOME") .. "/.config/rofi/scripts/rofi-web-search.sh"

-- ============================================================================
--  AUTOSTART
-- ============================================================================

hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
  hl.exec_cmd("systemctl --user import-environment")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("wl-clip-persist --clipboard regular")
  hl.exec_cmd("waypaper --restore")
  hl.exec_cmd("swaync")
  hl.exec_cmd("waybar")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/battery-notify.sh &")
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hyprctl/hyprctl.sh")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/airplane-mode.sh restore")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-kb.sh restore")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-tp.sh restore")
end)

-- exec-always equivalent: re-run on reload
hl.on("config.reloaded", function()
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hyprctl/hyprctl.sh")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-kb.sh restore")
  hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-tp.sh restore")
end)

-- ============================================================================
--  ENVIRONMENT VARIABLES
-- ============================================================================
-- Cursor
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt
hl.env("QT_QPA_PLATFORMTHEME",             "qt5ct")
hl.env("QT_SCALE_FACTOR",                  "1")
hl.env("QT_QPA_PLATFORM",                  "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR",      "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- NVIDIA
hl.env("LIBVA_DRIVER_NAME",         "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND",               "nvidia-drm")
hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__VK_LAYER_NV_optimus",     "NVIDIA_only")
hl.env("NVD_BACKEND",               "direct")
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")
hl.env("__GL_VRR_ALLOWED", "0")

-- Wayland
hl.env("XDG_SESSION_TYPE",            "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT","auto")

-- GTK
hl.env("GDK_SCALE",     "1")
hl.env("GDK_DPI_SCALE", "1")

-- ============================================================================
--  APPEARANCE
-- ============================================================================
local col_active_border   = "rgba(c4c4c4ee)"
local col_inactive_border = "rgba(1a1a1aee)"
local col_float_border    = "0xff848484"

hl.config({
  general = {
    gaps_in        = 0,
    gaps_out       = 0,
    border_size    = 2,
    col = {
      active_border   = col_active_border,
      inactive_border = col_inactive_border,
    },
    resize_on_border = false,
    allow_tearing    = false,
    layout           = "dwindle",
    snap = {
      enabled     = true,
      window_gap  = 10,
      monitor_gap = 10,
    },
  },

  decoration = {
    rounding       = 0,
    rounding_power = 0,
    active_opacity    = 0.95,
    inactive_opacity  = 0.85,
    fullscreen_opacity = 1.0,
    shadow = {
      enabled      = false,
      range        = 8,
      render_power = 2,
      color        = "rgba(00000026)",
    },
    blur = {
      enabled        = true,
      size           = 6,
      passes         = 2,
      ignore_opacity = true,
      noise          = 0.08,
      contrast       = 1.5,
      brightness     = 0.8,
      xray           = false,
    },
  },

  animations = {
    enabled = true,
  },
})

-- ============================================================================
--  ANIMATIONS
-- ============================================================================
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0}, {0.1, 1}  } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},    {1, 1}    } })
hl.curve("snap",         { type = "bezier", points = { {0.16, 1}, {0.3, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 3,   bezier = "default"      })
hl.animation({ leaf = "border",        enabled = true, speed = 4,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 2,   bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1.7, bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.5, bezier = "linear",       style = "popin 90%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 1.5, bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3,   bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,   bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 2,   bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2,   bezier = "quick" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.5, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,   bezier = "quick" })

-- ============================================================================
--  LAYOUTS
-- ============================================================================
hl.config({
  dwindle = {
    preserve_split = true,
  },
  master = {
    new_status = "master",
  },
})

-- ============================================================================
--  INPUT DEVICES
-- ============================================================================
hl.config({
  input = {
    kb_layout  = "us",
    kb_variant = "",
    kb_model   = "",
    kb_options = "",
    kb_rules   = "",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad = {
      natural_scroll = false,
    },
  },
})

hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})

-- NOTE: keyboard & touchpad enabled state is managed by toggle scripts.
-- Do NOT add hl.device() with enabled = true/false here or it will
-- override the toggle state on every config reload.

-- --- Touchpad Gestures ---
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ============================================================================
--  MISCELLANEOUS
-- ============================================================================
hl.config({
  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = false,
  },
})

-- ============================================================================
--  KEYBINDINGS
-- ============================================================================
local mainMod = "SUPER"

-- --- Applications ---
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D",      hl.dsp.exec_cmd("rofi -show drun -theme " .. rofi_theme))
hl.bind(mainMod .. " + R",      hl.dsp.exec_cmd("rofi -show run -theme " .. rofi_theme .. " -run-command 'kitty -e fish -c \"{cmd}; read\"'"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("rofi -show window -theme " .. rofi_theme))
hl.bind(mainMod .. " + W",      hl.dsp.exec_cmd(web_search))
hl.bind(mainMod .. " + N",      hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/rofi/scripts/wallpaper.sh"))

-- --- Window Management ---
hl.bind(mainMod .. " + C",           hl.dsp.window.close())
hl.bind(mainMod .. " + M",           hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + F",   hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + T",           hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"))

-- --- Focus Movement ---
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left"  }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up"    }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down"  }))

-- --- Resize Window ---
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -20, y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20,  y = 0,  relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }), { repeating = true })

-- --- Move Window in direction ---
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.swap({ direction = "left"  }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.swap({ direction = "up"    }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.swap({ direction = "down"  }))

-- --- Workspace Switching & Moving Windows ---
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- --- Numpad Workspace Switching & Moving Windows ---
local numpad_keys = {
  "KP_End", "KP_Down", "KP_Next",
  "KP_Left", "KP_Begin", "KP_Right",
  "KP_Home", "KP_Up", "KP_Prior",
  "KP_Insert",
}

for i, key in ipairs(numpad_keys) do
  local ws = i
  hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = ws }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws }))
end

-- --- Workspace Navigation ---
hl.bind("ALT + D", hl.dsp.focus({ workspace = "previous" }))
hl.bind("ALT + S", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + A", hl.dsp.focus({ workspace = "e-1" }))

-- --- Mouse Workspace Switching ---
hl.bind(mainMod .. " + mouse:275", hl.dsp.focus({ workspace = "e+1" }), { mouse = true })
hl.bind(mainMod .. " + mouse:276", hl.dsp.focus({ workspace = "e-1" }), { mouse = true })

-- --- Mouse Actions ---
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- Utilities ---
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(
  "rofi -dmenu -display-columns 2 -p '' -show-icons -theme " .. rofi_theme ..
  " -theme-str 'listview { columns: 1; }'" ..
  " < <(" .. os.getenv("HOME") .. "/.config/rofi/scripts/cliphist-rofi-img.sh)" ..
  " | xargs -I {} " .. os.getenv("HOME") .. "/.config/rofi/scripts/cliphist-rofi-img.sh {}"
))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd(
  "rofimoji --selector rofi --action clipboard --prompt '󰞅'" ..
  " --selector-args='-no-show-icons -theme " .. rofi_theme .. "'"
))
hl.bind(mainMod .. " + I",      hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/rofi/scripts/hypr-keybinds.sh"))
hl.bind(mainMod .. " + H",      hl.dsp.exec_cmd("killall -SIGUSR1 waybar"))
hl.bind(mainMod .. " + L",      hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + F12", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-kb.sh"))
hl.bind(mainMod .. " + CTRL + F11", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-laptop-tp.sh"))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- --- Minimize ---
hl.bind(mainMod .. " + X", function ()
  if hl.get_workspace("special:minimized") then
    hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:minimized" }))
    hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:minimized" }))
  else
    hl.dispatch(hl.dsp.window.tag({ tag = "minimized", window = hl.get_active_window() }))
    hl.dispatch(hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
  end
end)

-- --- Screenshots ---
hl.bind("Print",               hl.dsp.exec_cmd("hyprshot -m output -m eDP-1 -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots/"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots/"))
hl.bind("CTRL + Print",        hl.dsp.exec_cmd("hyprshot -m window -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots/"))
hl.bind("SHIFT + Print",       hl.dsp.exec_cmd("hyprshot -m active -m window -z -o " .. os.getenv("HOME") .. "/Pictures/Screenshots/"))

-- --- Zoom ---
local MIN_ZOOM = 1
local MAX_ZOOM = 3
local ZOOM_TOGGLE_FACTOR = 1.5

local function zoom(mult)
  local z = hl.get_config("cursor.zoom_factor")
  local nz
  if mult ~= nil then
    nz = z * mult
  else
    nz = (z ~= MIN_ZOOM) and MIN_ZOOM or ZOOM_TOGGLE_FACTOR
  end
  nz = math.max(MIN_ZOOM, math.min(MAX_ZOOM, nz))
  hl.config({ cursor = { zoom_factor = nz } })
end

hl.bind(mainMod .. " + Z", zoom)
hl.bind(mainMod .. " + equal",       function() zoom(1.1) end, { repeating = true })
hl.bind(mainMod .. " + minus",       function() zoom(0.9) end, { repeating = true })
hl.bind(mainMod .. " + KP_ADD",      function() zoom(1.1) end, { repeating = true })
hl.bind(mainMod .. " + KP_SUBTRACT", function() zoom(0.9) end, { repeating = true })

-- --- Media Keys ---
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })

-- ============================================================================
--  WINDOW RULES
-- ============================================================================

-- Ignore maximize requests from apps
hl.window_rule({
  name           = "suppress-maximize",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
  name             = "fix-xwayland-drags",
  match            = { xwayland = true, float = true, fullscreen = false, pin = false },
  no_initial_focus = true,
})

-- border for tiled windows
hl.window_rule({
  match        = { float = false },
  border_color = col_active_border .. " " .. col_inactive_border,
})

-- border for floating windows
hl.window_rule({
  match        = { float = true },
  border_color = col_float_border .. " " .. col_float_border,
})

-- Firefox
hl.window_rule({
  match     = { class = "^firefox$" },
  workspace = "1",
  opacity   = "1.0 override 1.0 override 1.0 override",
})

-- Editors / IDE
hl.window_rule({ match = { class = "^code-oss$"    }, workspace = "2" })
hl.window_rule({ match = { class = "^antigravity$" }, workspace = "2" })
hl.window_rule({ match = { class = "^cursor$"      }, workspace = "2" })

-- Steam
hl.window_rule({ match = { class = "^steam$" }, workspace = "3 silent" })

-- Steam game windows
hl.window_rule({
  match = { class = "^steam_app_[0-9]+$" },
  immediate = true,
  opacity   = "1.0 override 1.0 override 1.0 override",
})

-- Discord (Vesktop)
hl.window_rule({ match = { class = "^vesktop$" }, workspace = "5 silent" })

-- Obsidian
hl.window_rule({ match = { class = "^md.Obsidian$" }, workspace = "4 silent" })

-- Spotify / Blanket
hl.window_rule({ match = { class = "^Spotify$"                       }, workspace = "6 silent" })
hl.window_rule({ match = { class = "^com.rafaelmardojai.Blanket$" }, workspace = "6 silent" })

-- gThumb
hl.window_rule({
  match  = { class = "^org.gnome.gThumb$" },
  size   = { 1400, 900 },
  float  = true,
  center = true,
})

-- Satty
hl.window_rule({
  match  = { class = "^com.gabm.satty$" },
  size   = { 1400, 900 },
  float  = true,
  center = true,
})

-- Picture in Picture
hl.window_rule({
  match = { title = "^Picture-in-Picture$" },
  float = true,
  pin   = true,
})

-- Always opaque
hl.window_rule({ match = { class = "^blender$" }, opacity = "1.0 override 1.0 override 1.0 override" })
hl.window_rule({ match = { class = "^gimp$"    }, opacity = "1.0 override 1.0 override 1.0 override" })
