---@diagnostic disable: undefined-global
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local function get_os_name()
	-- ask LuaJIT first
	if jit then
		return jit.os
	end

	-- Unix, Linux variants
	local fh = io.popen("uname -o 2>/dev/null", "r")
	if fh == nil then
		wezterm.log_error("Failed to run uname: " .. err)
		return "Windows"
	end

	local osname = fh:read() or "Windows"

	return osname
end

local function is_exec(cmd, is_windows)
	if is_windows then
		local f = io.popen("where " .. cmd)
		if f == nil then
			wezterm.log_error("Failed to run where " .. cmd)
			return false
		end
		local result = f:read("*all")
		f:close()

		return result ~= ""
	else
		return os.execute("which " .. cmd .. " > /dev/null 2>&1") == 0
	end
end

local current_os = get_os_name()

local preload = {
	--- @class QuickSelectPattern
	--- @field name string Name of the pattern
	--- @field desc string? Description for the pattern
	--- @field pattern string Regex pattern string
	--- @field open fun(text, window?, pane?) Operation to perform

	--- @type QuickSelectPattern[]
	quickselect_patterns = {
		{
			name = "sha256",
			pattern = "sha256-[^%s]+",
			open = function(text)
				wezterm.open_with(text)
			end,
		},
		{
			name = "http",
			pattern = "https?://[^%s]+",
			open = function(text)
				wezterm.open_with(text)
			end,
		},
		{
			name = "github_auth_code",
			pattern = "^%u%u%u%u%-%u%u%u%u$",
			open = function(text, window)
				window:copy_to_clipboard(text)
			end,
		},
		{
			name = "github_url",
			pattern = "[%w_%-]+/[%w_%-%.]+",
			open = function(text)
				local url = "https://github.com/" .. text
				wezterm.open_with(url)
			end,
		},
	},
}

wezterm.on("toggle-opacity", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.window_background_opacity then
		overrides.window_background_opacity = 0.9
	else
		overrides.window_background_opacity = nil
	end

	window:set_config_overrides(overrides)
end)

-- Default shell
local default_shell = os.getenv("SHELL")

if default_shell == nil then
	if current_os == "Windows" then
		if is_exec("nu", true) then
			default_shell = "nu"
		elseif is_exec("pwsh", true) then
			default_shell = "pwsh"
		elseif is_exec("powershell", true) then
			default_shell = "powershell"
		else
			default_shell = "cmd"
		end
	else
		if is_exec("fish", true) then
			default_shell = "fish"
		elseif is_exec("nu", true) then
			default_shell = "nu"
		else
			default_shell = "bash"
		end
	end
end
config.default_prog = { default_shell }

-- Colorscheme
config.color_scheme = "Catppuccin Mocha"

-- Font
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"CaskaydiaCove Nerd Font",
	"MesloLGS NF",
	"Noto Sans Mono CJK KR",
	"Menlo",
	"Monaco",
	"Courier New",
})
if current_os == "OSX" or current_os == "Darwin" then
	config.font_size = 14
else
	config.font_size = 11
end

-- Use the default hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Enable Kitty image protocol
config.enable_kitty_graphics = true

-- SSH
config.ssh_domains = {
	{
		-- The name of this specific domain.  Must be unique amongst
		-- all types of domain in the configuration file.
		name = "my.server",

		-- identifies the host:port pair of the remote server
		-- Can be a DNS name or an IP address with an optional
		-- ":port" on the end.
		remote_address = "192.168.1.1",

		-- Whether agent auth should be disabled.
		-- Set to true to disable it.
		-- no_agent_auth = false,

		-- The username to use for authenticating with the remote host
		username = "larpi",

		-- If true, connect to this domain automatically at startup
		-- connect_automatically = true,

		-- Specify an alternative read timeout
		-- timeout = 60,

		-- The path to the wezterm binary on the remote host.
		-- Primarily useful if it isn't installed in the $PATH
		-- that is configure for ssh.
		-- remote_wezterm_path = "/home/yourusername/bin/wezterm"
	},
}

-- Create unix domain socket
config.unix_domains = {
	{
		name = "unix",
	},
}

-- For persistent sessions
config.default_gui_startup_args = { "connect", "unix" }

-- Ligature
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Front End
config.front_end = "WebGpu"

-- FPS
config.max_fps = tonumber(os.getenv("WEZTERM_FPS")) or 60

-- Window
config.window_padding = {
	left = "3px",
	right = "3px",
	top = "3px",
	bottom = "3px",
}
config.window_background_image = wezterm.config_dir .. "/bg.jpg"
config.window_background_image_hsb = {
	brightness = 0.3,
}

config.inactive_pane_hsb = {
	saturation = 0.6,
	brightness = 0.4,
}

-- Windows
-- config.win32_system_backdrop = "Acrylic"

-- macOS
config.macos_window_background_blur = 10
config.native_macos_fullscreen_mode = true

-- Mouse
config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "NONE",
		action = wezterm.action.Nop,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- Keybindings

config.disable_default_key_bindings = false
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

local act = wezterm.action
local spawn_tab_next_to_active = wezterm.action_callback(function(win, pane)
	local mux_win = win:mux_window()
	-- Find the current tab index
	for _, item in ipairs(mux_win:tabs_with_info()) do
		if item.is_active then
			-- Spawn new tab and move it next to the current
			mux_win:spawn_tab({})
			win:perform_action(act.MoveTab(item.index + 1), pane)
			return
		end
	end
end)
config.keys = {
	{ key = "Space", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "CTRL|META", action = act.ActivateCommandPalette },
	{ key = "r", mods = "CTRL|SHIFT", action = "ReloadConfiguration" },
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = spawn_tab_next_to_active,
	},
	{
		key = "t",
		mods = "CMD",
		action = spawn_tab_next_to_active,
	},
	{ key = "w", mods = "META", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "Enter", mods = "CTRL|SHIFT", action = act.SpawnWindow },
	-- { key = "C", mods = "CTRL", action = act.CopyTo("ClipboardAndPrimarySelection") },
	-- { key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") },
	-- { key = "V", mods = "CTRL", action = act.PasteFrom("PrimarySelection") },
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-0.5) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(0.5) },
	{ key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
	{ key = "b", mods = "CTRL|SHIFT", action = wezterm.action.EmitEvent("toggle-opacity") },
	{
		-- Select URL to open
		key = "o",
		mods = "CTRL|SHIFT",
		action = act.QuickSelectArgs({
			label = "open",
			patterns = {
				"\\b[\\d\\w\\-_\\./=\\?#:\\\\]+\\b",
			},
			action = wezterm.action_callback(function(window, pane)
				local text = window:get_selection_text_for_pane(pane)

				for _, value in ipairs(preload.quickselect_patterns) do
					wezterm.log_info('Try matching text "' .. text .. '" to the pattern "' .. value.name .. '".')
					if text:match(value.pattern) then
						value.open(text, window, pane)
						return
					end
				end

				-- fallback
				window:copy_to_clipboard(text, "ClipboardAndPrimarySelection")
			end),
		}),
	},
}

local directions = { h = "Left", j = "Down", k = "Up", l = "Right" }

for key, direction in pairs(directions) do
	-- -- Adjust pane size
	-- config.keys[#config.keys + 1] = { key = key, mods = "META", action = act.AdjustPaneSize({ direction, 5 }) }
	--
	-- config.keys[#config.keys + 1] = { key = key, mods = "CTRL", action = act.ActivatePaneDirection(direction) }

	config.keys[#config.keys + 1] = {
		key = key,
		mods = "CTRL|SHIFT",
		action = act.SplitPane({
			direction = direction,
			command = { domain = "CurrentPaneDomain" },
			size = { Percent = 50 },
		}),
	}
end
config.keys[#config.keys + 1] = {
	key = "h",
	mods = "SUPER",
	action = act.ActivateTabRelative(-1),
}
config.keys[#config.keys + 1] = {
	key = "l",
	mods = "SUPER",
	action = act.ActivateTabRelative(1),
}
config.keys[#config.keys + 1] = {
	key = "h",
	mods = "SHIFT|SUPER",
	action = act.MoveTabRelative(-1),
}
config.keys[#config.keys + 1] = {
	key = "l",
	mods = "SHIFT|SUPER",
	action = act.MoveTabRelative(1),
}

-- # Plugins

local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")
modal.apply_to_config(config)
modal.set_default_keys(config)

local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
-- you can put the rest of your Wezterm config here
smart_splits.apply_to_config(config, {
	-- the default config is here, if you'd like to use the default keys,
	-- you can omit this configuration table parameter and just use
	-- smart_splits.apply_to_config(config)

	-- directional keys to use in order of: left, down, up, right
	-- if you want to use separate direction keys for move vs. resize, you
	-- can also do this:
	direction_keys = {
		move = { "h", "j", "k", "l" },
		resize = { "LeftArrow", "DownArrow", "UpArrow", "RightArrow" },
	},
	-- modifier keys to combine with direction_keys
	modifiers = {
		move = "CTRL", -- modifier to use for pane movement, e.g. CTRL+h to move left
		resize = "META", -- modifier to use for pane resize, e.g. META+h to resize to the left
	},
	-- log level to use: info, warn, error
	log_level = "info",
})

return config
