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

require("lazy").setup({
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },

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
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "Find Files"})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = "Find Grep"})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = "Find Buffers"})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "Find Help"})
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
        keys = {
            { "<leader>m", ":Mason<CR>", noremap = true, silent = true, desc = "Mason" }
        },
        config = function()
            require("mason").setup()
        end
    },

    {
        "kdheepak/lazygit.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>gg", ":LazyGit<CR>", noremap = true, silent = true, desc = "LazyGit" }
        }
    },


    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/nvim-cmp',
            'L3MON4D3/LuaSnip',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        keys = {
            {"<leader>cf", vim.lsp.buf.format, desc="Format Code", noremap=true, silent=true}
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })
            end)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = {},
                handlers = {
                    lsp_zero.default_setup,
                },
            })

            local cmp = require('cmp')
            local cmp_action = require('lsp-zero').cmp_action()

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    -- `Enter` key to confirm completion
                    ['<C-y>'] = cmp.mapping.confirm({ select = false }),

                    -- Ctrl+Space to trigger completion menu
                    ['<C-Space>'] = cmp.mapping.complete(),

                    -- Navigate between snippet placeholder
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

                    -- Scroll up and down in the completion documentation
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                })
            })
        end,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
        config = function()
            require("ibl").setup()
        end
    },
}
)
