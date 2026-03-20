return {
    entry = function()
        local output = Command("jj"):arg("status"):stderr(Command.PIPED):output()
        if output.stderr ~= "" then
            ya.notify({
                title = "jjui",
                content = "Not in a jj directory\nError: " .. output.stderr,
                level = "warn",
                timeout = 5,
            })
        else
            permit = ui.hide and ui.hide() or ya.hide()
            local output, err_code = Command("jjui"):stdin(Command.INHERIT):stdout(Command.INHERIT):stderr(Command.PIPED):spawn()
            if output and not err_code then
                output, err_code = output:wait_with_output()
            end
            if err_code ~= nil then
                ya.notify({
                    title = "Failed to run jjui command",
                    content = "Status: " .. err_code,
                    level = "error",
                    timeout = 5,
                })
            elseif not output.status.success then
                ya.notify({
                    title = "jjui in" .. cwd .. "failed, exit code " .. output.status.code,
                    content = output.stderr,
                    level = "error",
                    timeout = 5,
                })
            end
        end
    end,
}
