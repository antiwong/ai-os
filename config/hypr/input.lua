hl.config({
    input = {
        kb_layout = "us",
        repeat_rate = 40, repeat_delay = 300,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,        -- content follows fingers, like macOS
            tap_to_click = true,
            clickfinger_behavior = true,  -- 2-finger click = right click, 3-finger = middle (Mac style)
            disable_while_typing = true,  -- palm rejection
            drag_lock = 1,                -- keep dragging after lifting a finger briefly
        },
    },
    gestures = {
        workspace_swipe_distance = 400,   -- shorter, snappier workspace swipes
        workspace_swipe_cancel_ratio = 0.3,
        workspace_swipe_create_new = false,
    },
})

-- Trackpad gestures (macOS-like)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })           -- swipe between desktops
hl.gesture({ fingers = 3, direction = "up",    action = function() hl.exec_cmd("fuzzel") end })          -- Spotlight/Launchpad
hl.gesture({ fingers = 4, direction = "up",    action = function() hl.exec_cmd("ai-os-claude") end })    -- Claude scratchpad
hl.gesture({ fingers = 4, direction = "down",  action = function() hl.exec_cmd("ai-os-menu") end })      -- system menu
hl.gesture({ fingers = 3, direction = "swipe", mods = "SUPER", action = "move" })     -- hold SUPER + 3 fingers: move window
hl.gesture({ fingers = 4, direction = "swipe", mods = "SUPER", action = "resize" })   -- hold SUPER + 4 fingers: resize window
