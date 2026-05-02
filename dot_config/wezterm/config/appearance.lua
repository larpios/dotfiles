local wezterm = require('wezterm')
local theme = require('themes').catppuccin.mocha
local gpu_adapter = require('utils.gpu_adapter')
local platform = require('utils.platform')

local os_name = platform.os

local config = {}

-- Colorscheme
config.color_scheme = 'Catppuccin Mocha'

-- Font
config.font = wezterm.font_with_fallback({
    'JetBrainsMono Nerd Font',
    'CaskaydiaCove Nerd Font',
    'MesloLGS NF',
    'Noto Color Emoji',
    'Apple Color Emoji',
    'Noto Sans Mono CJK KR',
    'Menlo',
    'Monaco',
    'Courier New',
})

if os_name == 'mac' then
    config.font_size = 14
else
    config.font_size = 11
end

config.allow_square_glyphs_to_overflow_width = 'Always'
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Window
config.window_padding = { left = '3px', right = '3px', top = '3px', bottom = '3px' }
config.background = require('utils.backdrops'):get_initial()
config.inactive_pane_hsb = { saturation = 0.6, brightness = 0.4 }
config.macos_window_background_blur = 10
config.native_macos_fullscreen_mode = true

-- Rendering / Misc
config.front_end = 'WebGpu'
config.webgpu_preferred_adapter = gpu_adapter:pick_best()
config.max_fps = tonumber(os.getenv('WEZTERM_FPS')) or 60
config.enable_kitty_graphics = true
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Tab Bar Appearance
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false
config.status_update_interval = 1000

-- Make the tab bar taller
config.window_frame = {
    font = wezterm.font({ family = 'JetBrainsMono Nerd Font', weight = 'Bold' }),
}

config.colors = {
    tab_bar = {
        background = 'rgba(0, 0, 0, 0.4)',
        active_tab = {
            bg_color = 'rgba(0, 0, 0, 0)',
            fg_color = theme.text,
        },
        inactive_tab = {
            bg_color = 'rgba(0, 0, 0, 0)',
            fg_color = theme.subtext0,
        },
        inactive_tab_hover = {
            bg_color = 'rgba(0, 0, 0, 0)',
            fg_color = theme.text,
        },
        new_tab = {
            bg_color = 'rgba(0, 0, 0, 0)',
            fg_color = theme.subtext0,
        },
        new_tab_hover = {
            bg_color = 'rgba(0, 0, 0, 0)',
            fg_color = theme.text,
        },
    },
}

return config
