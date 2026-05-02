local wezterm = require('wezterm')
local platform = require('utils.platform')
local helpers = require('utils.helpers')
local Config = require('utils.config_builder')

-- Default shell logic
local default_shell = os.getenv('SHELL')
if default_shell == nil then
    if platform.is_win then
        local shells_prio = { 'nu', 'pwsh', 'powershell', 'cmd' }
        for _, shell in ipairs(shells_prio) do
            if helpers.is_exec(shell, true) then
                default_shell = shell
                break
            end
        end
    else
        local shells_prio = { 'nu', 'fish', 'bash' }
        for _, shell in ipairs(shells_prio) do
            if helpers.is_exec(shell, false) then
                default_shell = shell
                break
            end
        end
    end
end

-- Setup events
require('events.toggle_opacity').setup()
require('events.right_status').setup()
require('events.tab_title').setup()

-- Initialize backdrops
require('utils.backdrops'):scan_images_dir():random()

return Config:init()
    :append(require('config.shell'))
    :append({
        unix_domains = { { name = 'unix' } },
        default_gui_startup_args = { 'connect', 'unix' },
    })
    :append(require('config.appearance'))
    :append(require('config.keys')).options
