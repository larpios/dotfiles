return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "jose-elias-alvarez/null-ls.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.diagnostics.eslint,
                null_ls.builtins.completion.spell,
            }
        })
    end
}
