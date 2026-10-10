return {
  {
    "tri-cao/nvim-dbee",
    dir = "/Users/nix/projects/github/neovim/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      require("dbee").install()
    end,
    config = function()
      -- Keep Blink's completion keymaps, including <C-Space>, in DBee scratchpads.
      local mappings = vim.tbl_filter(function(mapping)
        return mapping.action ~= "complete"
      end, vim.deepcopy(require("dbee.config").default.editor.mappings))
      require("dbee").setup {
        editor = {
          completion = { auto = false },
          mappings = mappings,
        },
      }
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      -- Enter accepts only after explicitly selecting a completion item.
      opts.completion = opts.completion or {}
      opts.completion.list = opts.completion.list or {}
      opts.completion.list.selection = opts.completion.list.selection or {}
      opts.completion.list.selection.preselect = false
      opts.completion.list.selection.auto_insert = false
      opts.keymap = opts.keymap or {}
      local enter = opts.keymap["<CR>"] or { "accept", "fallback" }
      opts.keymap["<CR>"] = vim.list_extend({ require("dbee.completion.blink").continue_after_comma }, enter)
      opts.completion.trigger = opts.completion.trigger or {}
      local blocked = opts.completion.trigger.show_on_blocked_trigger_characters or { " ", "\n", "\t" }
      opts.completion.trigger.show_on_blocked_trigger_characters = function()
        local characters = type(blocked) == "function" and blocked() or blocked
        if not ({ sql = true, mysql = true, plsql = true })[vim.bo.filetype] then
          return characters
        end
        return vim.tbl_filter(function(char)
          return char ~= " " and char ~= "\n" and char ~= "\t"
        end, characters)
      end
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.dbee = {
        name = "DBee",
        module = "dbee.completion.blink",
        score_offset = 100,
      }
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      for _, filetype in ipairs { "sql", "mysql", "plsql" } do
        opts.sources.per_filetype[filetype] = { "dbee" }
      end
    end,
  },
}
