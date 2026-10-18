hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
    },

    decoration = {
        rounding = 20,
        rounding_power = 2,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },
})

hl.workspace_rule({ workspace = '1', monitor = 'DP-1', persistent = true, default_name = 'web' })
hl.workspace_rule({ workspace = '2', monitor = 'DP-1', persistent = true, default_name = 'code' })
hl.workspace_rule({ workspace = '3', monitor = 'DP-1', persistent = true, default_name = 'chat' })
hl.workspace_rule({ workspace = '4', monitor = 'DP-1', persistent = true, default_name = 'game' })
hl.workspace_rule({ workspace = '5', monitor = 'DP-1', persistent = true, default_name = 'design' })

local mainMod = 'SUPER'
local ipc = 'noctalia msg '

-- Core binds
hl.bind(mainMod .. '+Space', hl.dsp.exec_cmd(ipc .. 'panel-toggle launcher'))
hl.bind(mainMod .. '+D', hl.dsp.exec_cmd(ipc .. 'panel-toggle control-center'))
hl.bind(mainMod .. '+comma', hl.dsp.exec_cmd(ipc .. 'settings-toggle'))
hl.bind('ALT + Tab', hl.dsp.exec_cmd(ipc .. 'window-switcher hold'))

-- Media keys
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd(ipc .. 'volume-up'))
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd(ipc .. 'volume-down'))
hl.bind('XF86AudioMute', hl.dsp.exec_cmd(ipc .. 'volume-mute'))
hl.bind('XF86MonBrightnessUp', hl.dsp.exec_cmd(ipc .. 'brightness-up'))
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd(ipc .. 'brightness-down'))

-- Noctalia Settings
hl.window_rule({
    match = { class = 'dev.noctalia.Noctalia' },
    float = true,
    size = { 1080, 920 },
})


-- Add blur
hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})
