vim.keymap.set("n", "<Space>", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.termguicolors = true
vim.g.confirm = true

vim.o.tabstop = 4
vim.o.shiftwidth= 4
vim.o.expandtab = true
vim.o.scrolloff = 12
vim.o.smarttab = true

vim.g.timeout = false
vim.g.ttimeout = false


vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('highlight_yank', {}),
    desc = 'Hightlight selection on yank',
    pattern = '*',
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 200 }
    end,
})
