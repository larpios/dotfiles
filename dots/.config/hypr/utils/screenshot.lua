local M = {}

local notify = require('utils.notify')
local SCREENSHOT_DIR = os.getenv('HOME') .. '/Pictures/Screenshots'

---@param mode? 'full'|'region'|'window'|'focused'
---@param output? 'file'|'clipboard'
function M.screenshot(mode, output)
    mode = mode or 'full'
    output = output or 'clipboard'

    local timestamp = os.date('%Y-%m-%d-%H-%M-%S')
    local dest = string.format('%s/%s.png', SCREENSHOT_DIR, timestamp)

    -- Build the region selection command
    local region_cmd = ''
    if mode == 'region' then
        region_cmd = 'slurp'
    elseif mode == 'window' then
        region_cmd = 'hyprctl clients -j | jq -r ".[] | \\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\\"" | slurp'
    elseif mode == 'focused' then
        region_cmd = 'hyprctl activewindow -j | jq -r "\\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\\""'
    end

    -- Build the grim command
    local grim_cmd = 'grim'
    if region_cmd ~= '' then
        -- We use a subshell to capture the region. If it fails (e.g. Escape), we notify and exit.
        local cancel_notify = notify.get_notify_cmd('Screenshot cancelled')
        grim_cmd = string.format('region=$(%s) || { %s; exit 1; }; grim -g "$region"', region_cmd, cancel_notify)
    end

    -- Build the final execution string
    local final_cmd
    if output == 'file' then
        local success_notify = notify.get_notify_cmd(string.format('Screenshot (%s) saved to %s', mode, dest))
        final_cmd = string.format('mkdir -p "%s" && %s "%s" && %s', SCREENSHOT_DIR, grim_cmd, dest, success_notify)
    else
        local success_notify = notify.get_notify_cmd(string.format('Screenshot (%s) copied to clipboard', mode))
        final_cmd = string.format('%s - | wl-copy && %s', grim_cmd, success_notify)
    end

    -- Wrap in bash to handle variables and logic asynchronously
    hl.exec_cmd(string.format('bash -c \'%s\'', final_cmd))
end

return M
