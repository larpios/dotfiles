return {
    "nvim-tree/nvim-tree.lua",
    config = function()
        vim.g.load_netrw = 1
        vim.g.load_netrwPlugin = 1
        vim.opt.termguicolors = true
        vim.keymap.set("n", "<leader>to", "<cmd>NvimTreeOpen<cr>",
            { desc = "Open NvimTree", noremap = true, silent = true })
        vim.keymap.set("n", "<leader>tc", "<cmd>NvimTreeClose<cr>",
            { desc = "Close NvimTree", noremap = true, silent = true })
        require("nvim-tree").setup()
    end,
}
