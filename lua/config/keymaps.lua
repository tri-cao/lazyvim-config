-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "gh", vim.diagnostic.open_float, { desc = "Show diagnostic" })

vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path" })
end, { desc = "Copy file path" })

vim.keymap.set("v", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local ref = path .. ":" .. start_line .. "-" .. end_line
  vim.fn.setreg("+", ref)
  vim.notify(ref, vim.log.levels.INFO, { title = "Copied reference" })
end, { desc = "Copy file:line ref" })

vim.keymap.set("n", "<D-S-.>", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })

vim.keymap.set("n", "<D-S-,>", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })

vim.keymap.set("n", "<D-/>", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<D-/>", "gc", { desc = "Toggle comment", remap = true })
vim.keymap.set("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })

vim.keymap.set("n", "<D-S-l>", "<leader>af", { remap = true, desc = "Claude (via leader af)" })
vim.keymap.set("t", "<D-S-l>", "<C-\\><C-n><leader>ac", { remap = true, desc = "Claude (via leader ac)" })
vim.keymap.set("v", "<D-S-l>", "<leader>as", { remap = true, desc = "Claude selection (via leader as)" })

vim.keymap.set("n", "<leader>ff", "<leader>fF", { remap = true, desc = "Find files (cwd)" })
vim.keymap.set("n", "<D-.>", "<leader>ca", { remap = true, desc = "Code Action" })

vim.keymap.set("n", "<leader>gd", "<cmd>CodeDiff history HEAD~20 %<CR>", { desc = "CodeDiff history HEAD~30" })
vim.keymap.set("n", "<leader>gg", "<cmd>CodeDiff<CR>", { desc = "CodeDiff" })

vim.keymap.set({ "n", "t" }, "<D-S-j>", function()
  -- Use Neovim's cwd (not LazyVim.root(), which picks the submodule root) so the
  -- terminal is the same from every buffer. Inside a terminal, just hide it.
  if vim.bo.filetype == "snacks_terminal" then
    return vim.cmd("hide")
  end
  Snacks.terminal(nil, { cwd = vim.uv.cwd() })
end, { desc = "Terminal (Cwd)" })

-- Replace LazyVim's <leader>ft (terminal) with DBee search
pcall(vim.keymap.del, "n", "<leader>ft")
vim.keymap.set("n", "<leader>ft", "<cmd>Dbee search<cr>", { desc = "DBee search" })
