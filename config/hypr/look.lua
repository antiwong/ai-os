-- Colours come from scripts/ai-os-theme (falls back to Catppuccin Mocha)
local ok, t = pcall(dofile, os.getenv("HOME") .. "/.config/ai-os/theme/hypr.lua")
if not ok then
    t = { active = { "rgba(cba6f7ee)", "rgba(b4befeee)" }, inactive = "rgba(45475aaa)", shadow = 0xee11111b }
end
hl.config({
    general = {
        gaps_in = 6, gaps_out = 12, border_size = 1,
        col = {
            active_border   = { colors = t.active, angle = 45 },
            inactive_border = t.inactive,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12,
        active_opacity = 1.0, inactive_opacity = 0.96,
        -- macOS-style: large, soft, slightly offset shadow
        shadow = { enabled = true, range = 40, render_power = 3, color = 0x55000000, offset = "0 12" },
        -- frosted-glass blur behind translucent windows
        blur = { enabled = true, size = 10, passes = 3, vibrancy = 0.2, noise = 0.02, brightness = 1.0, contrast = 1.0 },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    misc = { force_default_wallpaper = 0, disable_hyprland_logo = true },
})

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("spring",       { type = "bezier", points = { {0.34, 1.35}, {0.64, 1} } })
hl.curve("quick",        { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })
hl.animation({ leaf = "global",     enabled = true, speed = 10,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",    enabled = true, speed = 4,   bezier = "easeOutQuint", style = "popin 85%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3,   bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,   bezier = "spring",       style = "slide" })
