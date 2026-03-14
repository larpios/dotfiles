---@diagnostic disable: undefined-global
local function get_os_name()
	-- ask LuaJIT first
	if jit then
		return jit.os
	end

	-- Unix, Linux variants
	local fh, _err = assert(io.popen("uname -o 2>/dev/null", "r"))

	local osname = fh:read() or "Windows"

	return osname
end

local wezterm = require("wezterm")
local config = wezterm.config_builder()

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
		overrides.window_background_opacity = 0.7
	else
		overrides.window_background_opacity = nil
	end

	window:set_config_overrides(overrides)
end)

-- Default shell
local is_windows = current_os == "Windows"
local default_shell = is_windows or "pwsh.exe" and os.getenv("SHELL")
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
	config.font_size = 16
else
	config.font_size = 13
end
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
	brightness = 0.1,
}
config.window_background_opacity = 0.9

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
}

-- Keybindings

config.disable_default_key_bindings = false
local act = wezterm.action
--
--  [ CTRL = CMD ]
--   [ ALT = OPT ]
config.keys = {
	{ key = "Space", mods = "CTRL|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "CTRL|ALT", action = act.ActivateCommandPalette },
	{ key = "r", mods = "CTRL|SHIFT", action = "ReloadConfiguration" },
	-- { key = "t", mods = "CTRL", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
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
	{ key = "B", mods = "CTRL", action = wezterm.action.EmitEvent("toggle-opacity") },
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
	-- config.keys[#config.keys + 1] = { key = key, mods = "ALT", action = act.AdjustPaneSize({ direction, 5 }) }
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
	direction_keys = { "h", "j", "k", "l" },
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
