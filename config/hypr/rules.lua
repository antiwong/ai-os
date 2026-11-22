hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
    name = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Claude Code scratchpad (scripts/ai-os-claude): floating, centred, on special:claude
hl.window_rule({
    name = "claude-scratchpad",
    match = { class = "^ai-os[.]claude$" },
    workspace = "special:claude",
    float = true,
    size = "monitor_w*0.75 monitor_h*0.75",
    center = true,
})

-- Floating TUI popups launched from waybar (scripts/ai-os-popup)
hl.window_rule({
    name = "tui-popup",
    match = { class = "^ai-os[.]popup$" },
    float = true,
    size = "900 600",
    center = true,
})

-- Frosted menu bar / launcher / notifications (blur behind translucent layers)
for _, ns in ipairs({ "waybar", "fuzzel", "notifications", "swayosd" }) do
    hl.layer_rule({ name = "blur-" .. ns, match = { namespace = ns }, blur = true, ignore_alpha = 0.2 })
end
