-- Default: every monitor at its preferred mode, auto-placed, auto scale (laptop panel -> 1.5).
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Pin an external monitor to the right of the laptop panel (find names with `hyprctl monitors`):
-- hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "auto-right", scale = 1.5 })
-- Mirror the laptop panel onto a projector:
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
