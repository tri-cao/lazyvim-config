return {
  {
    "mgierada/lazydocker.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
    },
    cmd = { "Lazydocker" },
    keys = {
      {
        "<leader>td",
        function()
          require("lazydocker").open()
        end,
        desc = "Lazydocker",
      },
    },
    opts = {
      border = "curved",
      width = 0.9,
      height = 0.9,
    },
  },
}
