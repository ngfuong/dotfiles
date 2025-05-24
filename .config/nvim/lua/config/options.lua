-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazy_picker = "fzf"
require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
vim.opt.iminsert = 0
vim.opt.imsearch = 0
