return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
        'BurntSushi/ripgrep',
        'sharkdp/fd',
        'nvim-treesitter/nvim-treesitter',
    },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "Find Files"})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = "Find Grep"})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = "Find Buffers"})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "Find Help"})
        vim.keymap.set('n', '<leader>fr', builtin.oldfiles, {desc = "[F]ind [R]ecent"})
        vim.keymap.set('n', '<leader>fm', builtin.marks, {desc = "[F]ind [M]arks"})

        local telescope = require('telescope')
        local actions =  require('telescope.actions')
        telescope.setup ({
            defaults = {
                path_display = { "truncate "}, -- Example configuration
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })
    end,
    init = function ()
        require('telescope').load_extension("fzf")
    end
}
