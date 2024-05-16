return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        ensure_installed = {
            "c", "cpp", "lua", "vim", "vimdoc", "query", "python", "javascript", "markdown", "markdown_inline", "kotlin", "json",
        },
        auto_install = true,
        highlight = {
            enable = true,
        }
    }
}
