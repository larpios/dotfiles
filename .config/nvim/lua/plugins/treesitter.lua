return {
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
}
