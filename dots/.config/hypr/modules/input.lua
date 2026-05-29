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
    -- ZSA Navigator
    name = 'zsa-technology-labs-voyager-1',
    sensitivity = -0.8,
})
