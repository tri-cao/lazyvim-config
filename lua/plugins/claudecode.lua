return {
  "coder/claudecode.nvim",
  opts = {
    -- Command used to launch Claude (change to a custom path, wrapper, or add flags)
    terminal_cmd = "claude",
    -- Environment variables for the Claude terminal (no shell expansion, so expand ~ manually)
    env = {
      CLAUDE_CONFIG_DIR = vim.fn.expand("~/.claude"),
    },
  },
}
