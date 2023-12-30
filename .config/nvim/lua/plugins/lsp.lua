return {
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
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                -- see :help lsp-zero-keybindings
                -- to learn the available actions
                lsp_zero.default_keymaps({ buffer = bufnr })
                vim.keymap.set("n", "gl", vim.lsp.diagnostic.open_float, {desc="Show Diagnostic"})
            end)

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = {
                    "tsserver",
                    "rust_analyzer",
                    "pyright",
                    "lua_ls",
                    "clangd",
                    "vimls",
                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },
}
