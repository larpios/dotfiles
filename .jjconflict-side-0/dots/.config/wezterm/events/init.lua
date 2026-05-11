local M = {}

function M.setup()
    require('events.toggle_opacity').setup()
    require('events.right_status').setup()
    require('events.tab_title').setup()
end

return M
