local wezterm = require('wezterm')
local theme = require('themes').catppuccin.mocha

local M = {}

function M.setup()
    wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
        local title = tab.active_pane.title

        -- Manually truncate the title so the right rounded edge isn't cut off by tab_max_width.
        -- We need space for the prefix ("1: ") and the edge characters (" " and " ").
        local prefix = tostring(tab.tab_index + 1) .. ': '
        local padding = wezterm.column_width(prefix) + 4 -- 2 cells for left edge + 2 cells for right edge

        if max_width > padding then
            title = wezterm.truncate_right(title, max_width - padding)
        end

        local background = theme.surface0
        local foreground = theme.text
        local edge_background = 'rgba(0, 0, 0, 0.4)' -- Match the tab_bar background

        if tab.is_active then
            background = theme.mauve
            foreground = theme.crust
        elseif hover then
            background = theme.surface2
            foreground = theme.text
        end

        return {
            { Attribute = { Intensity = 'Bold' } },
            { Background = { Color = edge_background } },
            { Foreground = { Color = background } },
            { Text = ' ' },
            { Background = { Color = background } },
            { Foreground = { Color = foreground } },
            { Text = tab.tab_index + 1 .. ': ' .. title },
            { Background = { Color = edge_background } },
            { Foreground = { Color = background } },
            { Text = '' },
        }
    end)
end

return M
