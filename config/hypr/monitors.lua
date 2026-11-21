-- Default: every monitor at its preferred mode, auto-placed, auto scale.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
-- Laptop panel (1920x1200, ~163 DPI) pinned to 1.0 for a full-size desktop.
-- Try 1.25 (1536x960) if text is too small; auto picks 1.5.
hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1 })

-- Pin an external monitor to the right of the laptop panel (find names with `hyprctl monitors`):
-- hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "auto-right", scale = 1.5 })
-- Mirror the laptop panel onto a projector:
-- hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
