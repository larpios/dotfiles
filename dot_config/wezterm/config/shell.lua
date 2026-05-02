local platform = require('utils.platform')

local function get_fallback_shell()
    if platform.is_win then
        local shells_prio = { 'nu', 'pwsh', 'powershell', 'cmd' }
        for _, shell in ipairs(shells_prio) do
            if helpers.is_exec(shell, true) then
                return shell
            end
        end
    else
        local shells_prio = { 'nu', 'fish', 'bash' }
        for _, shell in ipairs(shells_prio) do
            if helpers.is_exec(shell, false) then
                return shell
            end
        end
    end
end

local config = {}

local default_shell = os.getenv('SHELL') or get_fallback_shell()

config.default_prog = { default_shell }

return config
