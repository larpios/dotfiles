local wezterm = require('wezterm')
local theme = require('themes').catppuccin.mocha

local M = {}

function M.setup()
    wezterm.on('update-right-status', function(window, pane)
        local stat = window:active_workspace()
        local stat_color = theme.red
        local time = wezterm.strftime('%H:%M')

        window:set_right_status(wezterm.format({
            { Foreground = { Color = stat_color } },
            { Text = string.format('  󰇄 %s  ', stat) },
            { Foreground = { Color = theme.subtext0 } },
            { Text = string.format('󱑒 %s  ', time) },
        }))
    end)
end

return M
