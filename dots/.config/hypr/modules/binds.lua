local utils = require('utils')
local apps = require('modules.programs')

local main_mod = 'SUPER'

local LMB = 'mouse:272'
local RMB = 'mouse:273'
local MMB = 'mouse:274'

--- Create a keybind
---@param keys string[]|string
---@param dispatcher function|HL.Dispatcher
---@param opts? HL.BindOptions
local function keybind(keys, dispatcher, opts)
    local key = type(keys) == 'table' and table.concat(keys, ' + ') or keys
    ---@diagnostic disable-next-line: param-type-mismatch
    hl.bind(key, dispatcher, opts)
    return key
end

-- General Binds
keybind({ main_mod, 'Q' }, hl.dsp.exec_cmd(apps.terminal))
keybind({ main_mod, 'C' }, hl.dsp.window.close())
keybind(
    { main_mod, 'M' },
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
keybind({ main_mod, 'E' }, hl.dsp.exec_cmd(apps.fileManager))
keybind({ main_mod, 'F' }, hl.dsp.window.float({ action = 'toggle' }))
keybind({ main_mod, 'SHIFT',  'F' }, hl.dsp.window.fullscreen({ action = 'toggle' }))
keybind({ main_mod, 'Space' }, hl.dsp.exec_cmd(apps.app_menu))
keybind({ main_mod, 'W' }, hl.dsp.exec_cmd(apps.window_menu))
keybind({ main_mod, 'R' }, function()
    hl.exec_cmd('hyprctl reload')
    utils.notify('Reloaded config')
end)
keybind({ main_mod, 'P' }, hl.dsp.window.pseudo())
keybind({ main_mod, 'SHIFT', 'P' }, hl.dsp.window.pin())
-- hl.bind(mainMod, 'J', hl.dsp.layout('togglesplit'))

-- Move focus
keybind({ main_mod, 'H' }, hl.dsp.focus({ direction = 'left' }))
keybind({ main_mod, 'J' }, hl.dsp.focus({ direction = 'down' }))
keybind({ main_mod, 'K' }, hl.dsp.focus({ direction = 'up' }))
keybind({ main_mod, 'L' }, hl.dsp.focus({ direction = 'right' }))

-- Move window
keybind({ main_mod, 'SHIFT', 'H' }, hl.dsp.window.swap({ direction = 'left' }))
keybind({ main_mod, 'SHIFT', 'J' }, hl.dsp.window.swap({ direction = 'down' }))
keybind({ main_mod, 'SHIFT', 'K' }, hl.dsp.window.swap({ direction = 'up' }))
keybind({ main_mod, 'SHIFT', 'L' }, hl.dsp.window.swap({ direction = 'right' }))

---@param direction 'left'|'right'|'up'|'down'
local function win_resize(direction)
    local active_monitor = hl.get_active_monitor() or { width = 1920, height = 1080 }
    local SCALE = 0.05
    local WIDTH_INC = active_monitor.width * SCALE
    local HEIGHT_INC = active_monitor.height * SCALE

    if direction == 'left' then
        hl.dsp.window.resize({ x = -WIDTH_INC, y = 0, relative = true })
    elseif direction == 'right' then
        hl.dsp.window.resize({ x = WIDTH_INC, y = 0, relative = true })
    elseif direction == 'up' then
        hl.dsp.window.resize({ x = 0, y = -HEIGHT_INC, relative = true })
    elseif direction == 'down' then
        hl.dsp.window.resize({ x = 0, y = HEIGHT_INC, relative = true })
    end
end

keybind({ main_mod, 'ALT', 'H' }, function()
    win_resize('left')
end)
keybind({ main_mod, 'ALT', 'J' }, function()
    win_resize('down')
end)
keybind({ main_mod, 'ALT', 'K' }, function()
    win_resize('up')
end)
keybind({ main_mod, 'ALT', 'L' }, function()
    win_resize('right')
end)
-- Workspaces
for i = 1, 10 do
    local key = i % 10
    keybind({ main_mod .. ' + ' .. key }, hl.dsp.focus({ workspace = i }))
    keybind({ main_mod .. ' + SHIFT + ' .. key }, hl.dsp.window.move({ workspace = i }))
end

-- Mouse binds
-- mouse:272 = LMB
-- mouse:273 = RMB
-- mouse:274 = MMB
keybind({ main_mod, 'mouse_down' }, hl.dsp.focus({ workspace = 'e+1' }))
keybind({ main_mod, 'mouse_up' }, hl.dsp.focus({ workspace = 'e-1' }))
keybind({ main_mod, LMB }, hl.dsp.window.drag(), { mouse = true })
keybind({ main_mod, RMB }, hl.dsp.window.resize(), { mouse = true })

-- Screenshots
keybind({ main_mod, 'S' }, function()
    utils.screenshot('full', 'clipboard')
end)
keybind({ main_mod, 'ALT', 'S' }, function()
    utils.screenshot('window', 'clipboard')
end)
keybind({ main_mod, 'SHIFT', 'S' }, function()
    utils.screenshot('focused', 'clipboard')
end)
keybind({ main_mod, 'ALT', 'SHIFT', 'S' }, function()
    utils.screenshot('region', 'clipboard')
end)

-- Multimedia keys
keybind(
    'XF86AudioRaiseVolume',
    hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'),
    { locked = true, repeating = true }
)
keybind(
    'XF86AudioLowerVolume',
    hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'),
    { locked = true, repeating = true }
)
keybind(
    'XF86AudioMute',
    hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),
    { locked = true, repeating = true }
)
keybind(
    'XF86AudioMicMute',
    hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),
    { locked = true, repeating = true }
)
keybind('XF86MonBrightnessUp', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%+'), { locked = true, repeating = true })
keybind('XF86MonBrightnessDown', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%-'), { locked = true, repeating = true })

keybind('XF86AudioNext', hl.dsp.exec_cmd('playerctl next'), { locked = true })
keybind('XF86AudioPause', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
keybind('XF86AudioPlay', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
keybind('XF86AudioPrev', hl.dsp.exec_cmd('playerctl previous'), { locked = true })
