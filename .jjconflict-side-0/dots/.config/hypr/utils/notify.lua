local M = {}

local fn = require('utils.fn')

---@class notifyOpts
---@field timeout integer Timeout in milliseconds
---@field color string Hex color string
---@field font_size number Font size

---@param msg string Messages to show
---@param opts? notifyOpts Options
---@return string cmd The hyprctl command string
function M.get_notify_cmd(msg, opts)
    local default_opts = {
        timeout = 3000,
        color = 'c6a0f6',
        font_size = 20,
    }
    opts = fn.tbl_merge(default_opts, opts, 'force')
    return string.format('hyprctl notify -1 %d "rgb(%s)" fontsize:%d "%s"', opts.timeout, opts.color, opts.font_size, msg)
end

---@param msg string Messages to show
---@param opts? notifyOpts Options
function M.notify(msg, opts)
    hl.exec_cmd(M.get_notify_cmd(msg, opts))
end

return M
