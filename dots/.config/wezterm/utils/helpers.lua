local wezterm = require('wezterm')
local platform = require('utils.platform')

local M = {}

---Check if a command is executable
---@param cmd string The command to check
---@param is_windows boolean Whether the OS is Windows
---@return boolean is_exec Whether the command is executable
function M.is_exec(cmd, is_windows)
    if platform.is_win then
        local f = io.popen('where ' .. cmd)
        if f == nil then
            wezterm.log_error('Failed to run where ' .. cmd)
            return false
        end
        local result = f:read('*all')
        f:close()
        return result ~= ''
    else
        return os.execute('which ' .. cmd .. ' > /dev/null 2>&1') == 0
    end
end

return M
