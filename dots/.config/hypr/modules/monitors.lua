for _, monitor in pairs(hl.get_monitors()) do
    hl.monitor({
        output = monitor.name,
        mode = 'highrr',
        position = 'auto',
        scale = 'auto',
    })
end
