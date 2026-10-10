return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true

      local theme_highlights = opts.highlights
      opts.highlights = function(defaults)
        local highlights = type(theme_highlights) == "function" and theme_highlights(defaults)
          or vim.deepcopy(theme_highlights or {})
        local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
        local fill_bg = "NONE"
        if bg then
          -- Blend in 3% white to keep the contrast subtle.
          local function lighten(shift)
            local channel = math.floor(bg / 2 ^ shift) % 256
            return math.floor(channel + (255 - channel) * 0.03 + 0.5)
          end
          fill_bg = string.format("#%02x%02x%02x", lighten(16), lighten(8), lighten(0))
        end
        highlights.fill = vim.tbl_extend("force", highlights.fill or {}, {
          bg = fill_bg,
        })
        return highlights
      end
    end,
  },
}
