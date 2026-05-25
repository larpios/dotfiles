hl.window_rule({
    name = 'suppress-maximize-events',
    match = { class = '.*' },
    suppress_event = 'maximize',
})

hl.window_rule({
    name = 'kitty',
    match = { class = '^kitty' },
    workspace = 1,
})

hl.window_rule({
    name = 'wezterm',
    match = {
        class = '^org.wezfurlong.wezterm',
        float = false,
    },
    workspace = 1,
})

hl.window_rule({
    name = 'browser',
    match = { class = '^(zen|floorp|firefox)' },
    workspace = 2,
})

hl.window_rule({
    name = 'discord',
    match = { class = '^discord' },
    workspace = 3,
})

hl.window_rule({
    name = 'steam',
    match = { class = '^steam' },
    workspace = 4,
    maximize = true,
    float = false,
})

hl.window_rule({
    name = 'steam-floats',
    match = {
        class = '^steam',
        title = 'negative:steam',
    },
    workspace = 4,
    float = true,
})

hl.window_rule({
    name = 'steam_games',
    match = { class = '^steam_app_.*' },
    workspace = 5,
    fullscreen = true,
})

hl.window_rule({
    name = 'pip',
    match = {
        title = '^(?i)picture-in-picture',
    },
    float = true,
    fullscreen = false,
    maximize = false,
    center = false,
    pin = true,
    content = 'video',
    size = { 'monitor_w * 0.25', 'monitor_h * 0.25' },
    move = { '(monitor_w * 0.99) - window_w', '(monitor_h * 0.99) - window_h' },
})

hl.window_rule({
    name = 'fix-xwayland-drags',
    match = {
        class = '^$',
        title = '^$',
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = 'move-hyprland-run',
    match = { class = 'hyprland-run' },
    move = '20 monitor_h-120',
    float = true,
})
