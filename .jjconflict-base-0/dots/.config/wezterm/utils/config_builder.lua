local wezterm = require("wezterm")

---@class ConfigBuilder
---@field options table
local Config = {}
Config.__index = Config

---Initialize Config
---@return ConfigBuilder
function Config:init()
	local config = setmetatable({ options = {} }, self)
	return config
end

---Deep merge two tables
---@param t1 table
---@param t2 table
---@return table
local function deep_merge(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k] or false) == "table" then
				deep_merge(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

---Append to `Config.options`
---@param new_options table new options to append
---@return ConfigBuilder
function Config:append(new_options)
	for k, v in pairs(new_options) do
		if self.options[k] ~= nil then
			if type(self.options[k]) == "table" and type(v) == "table" then
				self.options[k] = deep_merge(self.options[k], v)
			else
				wezterm.log_warn("Duplicate config option detected: ", { old = self.options[k], new = new_options[k] })
				goto continue
			end
		else
			self.options[k] = v
		end
		::continue::
	end
	return self
end

return Config
