--- Uncomment the two plugins below if you want to manage the language servers from neovim

return {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'neovim/nvim-lspconfig' },
        { 'hrsh7th/nvim-cmp' },
        { 'L3MON4D3/LuaSnip' },
        { 'williamboman/mason.nvim' },
        { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function()
        local lsp_zero = require('lsp-zero')

        lsp_zero.on_attach(function(client, bufnr)
            lsp_zero.default_keymaps({ buffer = bufnr, exclude = { '<F2>', '<F3>','<F4>'} })

            local function set(mode, lhs, rhs, opts)
                local _opts = {buffer = bufnr}
                _opts = opts and table.pack(_opts, opts) or _opts
                vim.keymap.set(mode, lhs, rhs, opts)
            end

            set('n', '<leader>clr', vim.lsp.buf.rename, { desc = "Rename Symbol"})
            set('n', '<leader>clf', vim.lsp.buf.format, { desc = "Format Buffer"})
            set('n', '<leader>cla', vim.lsp.buf.code_action, { desc = "Code Action"})
        end)

        require('mason').setup({})
        require('mason-lspconfig').setup({
            ensure_installed = { 'vimls', 'lua_ls'},
            handlers = {
                function(server_name)
                    require('lspconfig')[server_name].setup({})
                end,
            },
        })
    end

}
