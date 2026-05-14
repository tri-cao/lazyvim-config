return {
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = false },
      scroll = { enabled = false },
      dashboard = { animate = false },
      indent = { animate = { enabled = false } },
      picker = {
        sources = {
          explorer = {
            layout = {
              preset = "sidebar",
              layout = {
                position = "left",
                width = 40,
              },
            },
          },
        },
      },
    },
  },
}
