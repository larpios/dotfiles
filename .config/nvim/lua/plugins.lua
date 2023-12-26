-- Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
{
    "folke/which-key.nvim",
    {
        "nvim-tree/nvim-tree.lua",
        config = function() 
            vim.g.load_netrw = 1
            vim.g.load_netrwPlugin = 1
            vim.opt.termguicolors = true
            require("nvim-tree").setup()
        end,
    },
    { 
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin")
        end,
        opts = {
            transparent_background = true,
        },
    },
    { 
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end

    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "javascript"
            },
            auto_install = true,

            highlight = {
                enable = true,
            }
        }
    },
    {
        "phaazon/hop.nvim",
        lazy = true, 
        event = "BufRead",
        config = function()
            local hop = require('hop')
            local directions = require('hop.hint').HintDirection
            hop.setup({ keys = "etovxqpdygfblzhckisuran" })
            vim.keymap.set('', '<leader>hf', function()
                hop.hint_char1({ direction = directions.AFTER_CURSOR})
            end, {remap=true})
            vim.keymap.set('', '<leader>hF', function()
                hop.hint_char1({ direction = directions.BEFORE_CURSOR})
            end, {remap=true})
            vim.keymap.set('', '<leader>ht', function()
                hop.hint_char1({ direction = directions.AFTER_CURSOR, hint_offset = -1 })
            end, {remap=true})
            vim.keymap.set('', '<leader>hT', function()
                hop.hint_char1({ direction = directions.BEFORE_CURSOR, hint_offset = 1 })
            end, {remap=true})
        end

    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "ayu_mirage"
                }
            })
        end
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
            vim.keymap.set("", "<leader>m", ":Mason<CR>")
        end
    },
    {
        "kdheepak/lazygit.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            vim.keymap.set("", "<leader>gg", ":LazyGit<CR>", {desc="LazyGit"})
        end
    }

}
)
