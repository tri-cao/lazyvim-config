return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      underline = true,
      signs = true,
      float = { border = "rounded", source = true },
    },
  },
}
