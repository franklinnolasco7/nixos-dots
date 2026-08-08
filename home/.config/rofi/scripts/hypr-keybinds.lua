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
    if type(w) == "number" then return tostring(w) end
    return w or ""
end

local function comment_before(line)
    local f = io.open(config_path, "r")
    if not f then return "" end
    local lines = {}
    for l in f:lines() do lines[#lines + 1] = l end
    f:close()
    for i = math.min(line - 1, #lines), 1, -1 do
        local c = lines[i]:match("^%s*%-%-%s*(.*)%s*$") or ""
        c = c:gsub("^[-=]+%s*", ""):gsub("%s*[-=]+$", "")
        if c ~= "" then return c end
    end
    return ""
end

local function dsp_ret(dispatcher, arg)
    return { __dispatcher = dispatcher, __arg = arg or "" }
end

hl = {}      -- global: dofile'd config chunk needs to see it
hl.dsp = {}

-- register(path, fn) where fn(arg) returns dsp_ret; path may be dotted (window.close)
local function register(path, fn)
    local obj = hl.dsp
    local parts = {}
    for part in path:gmatch("[^.]+") do parts[#parts + 1] = part end
    local name = table.remove(parts)
    for _, p in ipairs(parts) do
        obj[p] = obj[p] or {}
        obj = obj[p]
    end
    obj[name] = function(...)
        return fn(select(1, ...))
    end
end

register("exec_cmd",      function(a) return dsp_ret("exec", tostring(a)) end)
register("exit",          function()   return dsp_ret("exit") end)
register("window.close",  function()   return dsp_ret("killactive") end)
register("window.fullscreen", function() return dsp_ret("fullscreen") end)
register("window.float",  function()   return dsp_ret("togglefloating") end)
register("window.swap",   function(a)  return dsp_ret("swapwindow", dir_short(a and a.direction)) end)
register("window.move",   function(a)  return dsp_ret("movetoworkspace", ws_arg(a and a.workspace)) end)
register("window.drag",   function()   return dsp_ret("movewindow", "mousemove") end)
register("window.resize", function()   return dsp_ret("resizewindow", "mousemove") end)
register("layout",        function()   return dsp_ret("togglesplit") end)
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

hl.monitor      = noop
hl.config       = noop
hl.env          = noop
hl.gesture      = noop
hl.on           = noop
hl.exec_cmd     = noop
hl.animation    = noop
hl.curve        = noop
hl.device       = noop
hl.window_rule  = noop

hl.bind = function(mods_key, dispatcher, opts)
    opts = opts or {}
    local parts = {}
    for raw_token in mods_key:gmatch("[^+]+") do
        local token = raw_token:gsub("^%s+", ""):gsub("%s+$", "")
        if token ~= "" then parts[#parts + 1] = token end
    end
    local key = table.remove(parts)
    local mods = table.concat(parts, " + ")

    local flags = {}
    if opts.mouse then flags[#flags + 1] = "mouse" end
    if opts.locked then flags[#flags + 1] = "locked" end
    if opts.repeating then flags[#flags + 1] = "repeat" end

    if type(dispatcher) ~= "table" then
        local info = debug.getinfo(dispatcher, "S")
        local line  = info and info.linedefined or 0
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
