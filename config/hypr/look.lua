-- Colours come from scripts/ai-os-theme (falls back to Catppuccin Mocha)
local ok, t = pcall(dofile, os.getenv("HOME") .. "/.config/ai-os/theme/hypr.lua")
if not ok then
    t = { active = { "rgba(cba6f7ee)", "rgba(b4befeee)" }, inactive = "rgba(45475aaa)", shadow = 0xee11111b }
end
hl.config({
    general = {
        gaps_in = 5, gaps_out = 10, border_size = 2,
        col = {
            active_border   = { colors = t.active, angle = 45 },
            inactive_border = t.inactive,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 8,
        active_opacity = 1.0, inactive_opacity = 1.0,
        shadow = { enabled = true, range = 8, render_power = 3, color = t.shadow },
        blur = { enabled = true, size = 3, passes = 2, vibrancy = 0.17 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.animation({ leaf = "global",     enabled = true, speed = 10,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4,   bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2,   bezier = "easeOutQuint", style = "fade" })
