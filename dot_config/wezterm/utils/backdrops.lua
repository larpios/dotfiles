local wezterm = require("wezterm")
local theme = require("themes").catppuccin.mocha

-- Seeding random numbers before generating for use
math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = "*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}"

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
function BackDrops:init()
	local backdrops = {
		current_idx = 1,
		images = {},
		images_dir = wezterm.config_dir .. "/backdrops/",
	}
	return setmetatable(backdrops, self)
end

---Override the default `images_dir`
function BackDrops:set_images_dir(path)
	self.images_dir = path
	if not path:match("/$") then
		self.images_dir = path .. "/"
	end
	return self
end

---Sets the `images` after instantiating `BackDrops`.
function BackDrops:scan_images_dir()
	local files = wezterm.glob(self.images_dir .. GLOB_PATTERN)
	if #files == 0 then
		-- Fallback to the root config dir if no backdrops folder or it's empty
		files = wezterm.glob(wezterm.config_dir .. "/" .. GLOB_PATTERN)
	end
	self.images = files
	return self
end

---Create the `background` options with the current image
---@private
function BackDrops:_gen_opts()
	local bg_opts = {}

	if #self.images > 0 then
		table.insert(bg_opts, {
			source = {
				File = { path = self.images[self.current_idx] },
			},
			-- hsb = { brightness = 0.1 },
			horizontal_align = "Center",
			vertical_align = "Middle",
		})
	end

	-- Add a dark dimming layer on top of the image to improve text readability
	table.insert(bg_opts, {
		source = { Color = theme.base },
		height = "120%",
		width = "120%",
		vertical_offset = "-10%",
		horizontal_offset = "-10%",
		opacity = 0.7, -- Subtle overlay
	})

	return bg_opts
end
---Set the initial options for `background`
function BackDrops:get_initial()
	return self:_gen_opts()
end

---Override the current window options for background
---@private
function BackDrops:_set_opt(window, background_opts)
	local overrides = window:get_config_overrides() or {}
	overrides.background = background_opts
	window:set_config_overrides(overrides)
end

---Convert the `images` array to a table of `InputSelector` choices
function BackDrops:choices()
	local choices = {}
	for idx, file in ipairs(self.images) do
		table.insert(choices, {
			id = tostring(idx),
			label = file:match("([^/]+)$"),
		})
	end
	return choices
end

---Select a random background from the loaded `files`
function BackDrops:random()
	if #self.images > 0 then
		self.current_idx = math.random(#self.images)
	end
	return self
end

---Set a specific background from the `files` array
---@param window Window
---@param idx number Index of the `files` array
function BackDrops:set_img(window, idx)
	if idx > #self.images or idx < 0 then
		wezterm.log_error("Index out of range")
		return
	end

	self.current_idx = idx
	self:_set_opt(window, self:_gen_opts())
end

return BackDrops:init()
