local wezterm = require('wezterm')
local Config = require('utils.config_builder')

-- Setup events
require('events.toggle_opacity').setup()
require('events.right_status').setup()
require('events.tab_title').setup()

-- Initialize backdrops
require('utils.backdrops'):scan_images_dir():random()

local ret = Config:init()
    :append(require('config.shell'))
    :append({
        unix_domains = { { name = 'unix' } },
        default_gui_startup_args = { 'connect', 'unix' },
    })
    :append(require('config.appearance'))
    :append(require('config.keys')).options

wezterm.log_info(ret)

return ret
