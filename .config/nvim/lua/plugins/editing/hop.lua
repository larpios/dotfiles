return {
    "phaazon/hop.nvim",
    lazy = true,
    event = "BufRead",
    config = function()
        local hop = require('hop')
        local directions = require('hop.hint').HintDirection
        hop.setup({ keys = "etovxqpdygfblzhckisuran" })
        vim.keymap.set('', '<leader>h/', function()
            hop.hint_words()
        end, { remap = true })
        vim.keymap.set('', '<leader>hf', function()
            hop.hint_char1({ direction = directions.AFTER_CURSOR })
        end, { remap = true })
        vim.keymap.set('', '<leader>hF', function()
            hop.hint_char1({ direction = directions.BEFORE_CURSOR })
        end, { remap = true })
        vim.keymap.set('', '<leader>ht', function()
            hop.hint_char1({ direction = directions.AFTER_CURSOR, hint_offset = -1 })
        end, { remap = true })
        vim.keymap.set('', '<leader>hT', function()
            hop.hint_char1({ direction = directions.BEFORE_CURSOR, hint_offset = 1 })
        end, { remap = true })
    end
}
