return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.routes = opts.routes or {}
    table.insert(opts.routes, 1, {
      filter = {
        event = "notify",
        find = "No information available",
      },
      opts = { skip = true },
    })
    opts.presets = opts.presets or {}
    opts.presets.lsp_doc_border = true
    return opts
  end,
}
