hl.config({
    input = {
        kb_layout = "us",
        repeat_rate = 40, repeat_delay = 300,
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = { natural_scroll = true, tap_to_click = true },
    },
})
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
