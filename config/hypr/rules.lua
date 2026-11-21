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
