local wezterm = require('wezterm')
local act = wezterm.action

---@class QuickSelectPattern
---@field name string
---@field pattern string
---@field open fun(text: string, window: wezterm.MuxWindow, pane: wezterm.Pane): nil

local preload = {
    --- @type QuickSelectPattern[]
    quickselect_patterns = {
        {
            name = 'sha256',
            pattern = 'sha256-[^%s]+',
            open = function(text, _, _)
                wezterm.copy_to_clipboard(text)
            end,
        },
        {
            name = 'http',
            pattern = 'https?://[^%s]+',
            open = function(text, _, _)
                wezterm.open_with(text)
            end,
        },
        {
            name = 'github_auth_code',
            pattern = '^%u%u%u%u%-%u%u%u%u$',
            open = function(text, window, _)
                window:copy_to_clipboard(text)
            end,
        },
        {
            name = 'github_url',
            pattern = '[%w_%-]+/[%w_%-%.]+',
            open = function(text, _, _)
                wezterm.open_with('https://github.com/' .. text)
            end,
        },
    },
}

local spawn_tab_next_to_active = wezterm.action_callback(function(win, pane)
    local mux_win = win:mux_window()
    for _, item in ipairs(mux_win:tabs_with_info()) do
        if item.is_active then
            mux_win:spawn_tab({})
            win:perform_action(act.MoveTab(item.index + 1), pane)
            return
        end
    end
end)

local config = {}

config.disable_default_key_bindings = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Leader Key (Tmux Style: Ctrl-A)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    -- Workspace operations via Leader
    { key = 's', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
    {
        key = '$',

        action = act.PromptInputLine({
            description = wezterm.format({
                { Attribute = { Intensity = 'Bold' } },
                { Foreground = { AnsiColor = 'Fuchsia' } },
                { Text = 'Enter new name for workspace' },
            }),
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
                end
            end),
        }),
    },
    { key = 'Space', mods = 'CTRL|SHIFT', action = act.DisableDefaultAssignment },
    { key = 'p', mods = 'CTRL|META', action = act.ActivateCommandPalette },
    { key = 'r', mods = 'CTRL|SHIFT', action = 'ReloadConfiguration' },
    { key = 't', mods = 'CTRL|SHIFT', action = spawn_tab_next_to_active },
    { key = 't', mods = 'CMD', action = spawn_tab_next_to_active },
    { key = 'w', mods = 'META', action = act.CloseCurrentPane({ confirm = true }) },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
    { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = true }) },
    { key = 'Enter', mods = 'CTRL|SHIFT', action = act.SpawnWindow },
    { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(0.5) },
    { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
    { key = "b", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-opacity") },
    {
    	key = "i",
    	mods = "CTRL|SHIFT",
    	action = wezterm.action_callback(function(window, pane)
    		local choices = backdrops:choices()
    		if #choices == 0 then
    			wezterm.log_info("No background images found")
    			return
    		end
    		window:perform_action(
    			act.InputSelector({
    				action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
    					if id then
    						backdrops:set_img(inner_window, tonumber(id))
    					end
    				end),
    				title = "Select Background",
    				choices = choices,
    				fuzzy = true,
    			}),
    			pane
    		)
    	end),
    },

    {
    	key = "y",
        mods = 'CTRL|SHIFT',
        action = act.QuickSelectArgs({
            label = 'copy',
            patterns = { '\\S+' },
            action = wezterm.action_callback(function(window, pane)
                local text = window:get_selection_text_for_pane(pane)
                window:copy_to_clipboard(text, 'ClipboardAndPrimarySelection')
            end),
        }),
    },

    -- Quick Select
    {
        key = 'o',
        mods = 'CTRL|SHIFT',
        action = act.QuickSelectArgs({
            label = 'open',
            patterns = { '\\b[\\d\\w\\-_\\./=\\?#:\\\\]+\\b' },
            action = wezterm.action_callback(function(window, pane)
                local text = window:get_selection_text_for_pane(pane)
                for _, value in ipairs(preload.quickselect_patterns) do
                    if text:match(value.pattern) then
                        value.open(text, window, pane)
                        return
                    end
                end
                window:copy_to_clipboard(text, 'ClipboardAndPrimarySelection')
            end),
        }),
    },
}

local directions = { h = 'Left', j = 'Down', k = 'Up', l = 'Right' }
for key, direction in pairs(directions) do
    table.insert(config.keys, {
        key = key,
        mods = 'CTRL|SHIFT',
        action = act.SplitPane({
            direction = direction,
            command = { domain = 'CurrentPaneDomain' },
            size = { Percent = 50 },
        }),
    })
end

table.insert(config.keys, { key = 'h', mods = 'SUPER', action = act.ActivateTabRelative(-1) })
table.insert(config.keys, { key = 'l', mods = 'SUPER', action = act.ActivateTabRelative(1) })
table.insert(config.keys, { key = 'h', mods = 'SHIFT|SUPER', action = act.MoveTabRelative(-1) })
table.insert(config.keys, { key = 'l', mods = 'SHIFT|SUPER', action = act.MoveTabRelative(1) })

config.mouse_bindings = {
    { event = { Up = { streak = 1, button = 'Left' } }, mods = 'NONE', action = act.Nop },
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    },
}

-- Plugins
local modal = wezterm.plugin.require('https://github.com/MLFlexer/modal.wezterm')
modal.apply_to_config(config)
modal.set_default_keys(config)

local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')
smart_splits.apply_to_config(config, {
    direction_keys = {
        move = { 'h', 'j', 'k', 'l' },
        resize = { 'LeftArrow', 'DownArrow', 'UpArrow', 'RightArrow' },
    },
    modifiers = { move = 'CTRL', resize = 'META' },
    log_level = 'info',
})

return config
