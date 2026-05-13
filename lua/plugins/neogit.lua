return {
  {
    "esmuellert/codediff.nvim",
    lazy = false,
    config = function()
      require("codediff").setup({
        diff = {
          layout = "side-by-side",
        },
        explorer = {
          view_mode = "tree",
        },
      })
    end,
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "esmuellert/codediff.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit Commit" },
      { "<leader>gp", "<cmd>Neogit push<cr>", desc = "Neogit Push" },
      { "<leader>gl", "<cmd>Neogit log<cr>", desc = "Neogit Log" },
    },
    opts = {
      integrations = {
        diffview = false,
        telescope = true,
      },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>gn", desc = "Neogit" },
        { "<leader>gc", desc = "Neogit Commit" },
        { "<leader>gp", desc = "Neogit Push" },
        { "<leader>gl", desc = "Neogit Log" },
      },
    },
  },
}
