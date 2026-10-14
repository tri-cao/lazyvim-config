-- gd: go to definition; if already on the definition, show references with snacks
local function goto_def_or_refs()
  vim.lsp.buf.definition({
    on_list = function(opts)
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      col = col + 1
      local file = vim.api.nvim_buf_get_name(0)
      for _, it in ipairs(opts.items) do
        if it.filename == file and it.lnum == row and col >= it.col and col <= (it.end_col or it.col) then
          return Snacks.picker.lsp_references()
        end
      end
      Snacks.picker.lsp_definitions()
    end,
  })
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "gd", goto_def_or_refs, desc = "Goto Definition / References", has = "definition" },
        },
      },
    },
  },
}
