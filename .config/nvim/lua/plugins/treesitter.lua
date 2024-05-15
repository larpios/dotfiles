return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {
            "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "javascript", "markdown", "kotlin", "json"
        },
        auto_install = true,
        highlight = {
            enable = true,
        }
    }
}
