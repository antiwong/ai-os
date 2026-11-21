local mod = "SUPER"
local terminal = "ghostty"
local files    = "dolphin"
local browser  = "google-chrome-stable"
local launcher = "fuzzel"

-- Apps
hl.bind(mod .. " + RETURN",    hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SPACE",     hl.dsp.exec_cmd(launcher))
hl.bind(mod .. " + F",         hl.dsp.exec_cmd(files))
hl.bind(mod .. " + B",         hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + C",         hl.dsp.exec_cmd("ai-os-claude"))
hl.bind(mod .. " + G",         hl.dsp.exec_cmd(terminal .. " -e lazygit"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd(terminal .. " -e lazydocker"))

-- System menu (screenshot, update, lock, power)
hl.bind(mod .. " + ESCAPE",    hl.dsp.exec_cmd("ai-os-menu"))

hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("ai-os-theme"))

-- Windows
hl.bind(mod .. " + W",         hl.dsp.window.close())
hl.bind(mod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + left",      hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",        hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",      hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Workspaces: SUPER+1..0, SUPER+SHIFT+1..0 moves the window
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad
hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Screenshots: Print = region to clipboard, SHIFT = annotate in satty, SUPER = whole output
hl.bind("Print",               hl.dsp.exec_cmd("ai-os-shot region"))
hl.bind("SHIFT + Print",       hl.dsp.exec_cmd("ai-os-shot region annotate"))
hl.bind(mod .. " + Print",     hl.dsp.exec_cmd("ai-os-shot output"))
hl.bind(mod .. " + SHIFT + Print", hl.dsp.exec_cmd("ai-os-shot window"))
-- Clipboard history picker (cliphist)
hl.bind(mod .. " + CTRL + V",  hl.dsp.exec_cmd("sh -c 'cliphist list | fuzzel --dmenu | cliphist decode | wl-copy'"))

-- Lock
hl.bind(mod .. " + L",         hl.dsp.exec_cmd("loginctl lock-session"))

-- Session: exit via uwsm (falls back to hyprctl)
hl.bind(mod .. " + SHIFT + E", hl.dsp.exec_cmd("sh -c 'uwsm stop || hyprctl dispatch exit'"))

-- Media keys (swayosd-client shows the OSD)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"),     { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),        { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"),        { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
