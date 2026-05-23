hl.config({
    input = {
        kb_layout = 'us',
        follow_mouse = 2,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
        repeat_rate = 40,
        repeat_delay = 150,
    },
})

hl.gesture({
    fingers = 3,
    direction = 'horizontal',
    action = 'workspace',
})

hl.device({
    name = 'epic-mouse-v1',
    sensitivity = -1.0,
})
