-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP Server to use for Python.
-- Set to "basedpyright" to use basedpyright instead of pyright.
-- "pyrefly" has no first-class LazyVim support, but the extra enables any server name given here
-- (config comes from nvim-lspconfig's lsp/pyrefly.lua; binary must be on PATH).
vim.g.lazyvim_python_lsp = "pyrefly"
vim.g.lazyvim_python_ruff = "ruff"

vim.lsp.handlers["$/progress"] = function() end

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ " -- Dấu hiệu wrap
vim.opt.textwidth = 0 -- Tắt hard wrap

-- Don't equalize all window sizes when a window is opened/closed
vim.opt.equalalways = false
