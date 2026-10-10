local dialects = {
  bigquery = "bigquery",
  clickhouse = "clickhouse",
  databricks = "databricks",
  duck = "duckdb",
  duckdb = "duckdb",
  mysql = "mysql",
  oracle = "oracle",
  pg = "postgres",
  postgres = "postgres",
  postgresql = "postgres",
  redshift = "redshift",
  sqlite = "sqlite",
  sqlite3 = "sqlite",
  mssql = "tsql",
  sqlserver = "tsql",
}

local config_files = { ".sqlfluff", "pep8.ini", "pyproject.toml", "setup.cfg", "tox.ini" }
local sql_filetypes = { sql = true, mysql = true, plsql = true }

local function dbee_dialect(bufnr)
  -- Inspect DBee only after it has loaded; ordinary SQL files need no DBee setup.
  local core = package.loaded["dbee.api.core"]
  local ui = package.loaded["dbee.api.ui"]
  if not (core and ui and core.is_loaded() and ui.is_loaded()) then
    return
  end

  local note, namespace = ui.editor_search_note_with_buf(bufnr)
  if not note then
    return
  end

  -- Connection scratchpads retain their own dialect during background formatting.
  -- Global notes run against DBee's currently selected connection.
  local connection
  if namespace == "global" then
    connection = core.get_current_connection()
  else
    connection = core.connection_get_params(namespace)
  end
  return connection and dialects[connection.type]
end

local function sqlfluff_args(bufnr, filename)
  local args = { "format" }
  local dialect = dbee_dialect(bufnr)
  if not dialect and not vim.fs.root(vim.fs.dirname(filename) or vim.fn.getcwd(), config_files) then
    dialect = ({ mysql = "mysql", plsql = "oracle" })[vim.bo[bufnr].filetype] or "ansi"
  end
  if dialect then
    table.insert(args, "--dialect=" .. dialect)
  end
  if filename ~= "" then
    vim.list_extend(args, { "--stdin-filename", filename })
  end
  table.insert(args, "-")
  return args
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        sqlfluff = {
          require_cwd = false,
          args = function(_, ctx)
            return sqlfluff_args(ctx.buf, ctx.filename)
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    init = function()
      local group = vim.api.nvim_create_augroup("SqlfluffManualFormat", { clear = true })
      local function configure_buffer(bufnr)
        if not sql_filetypes[vim.bo[bufnr].filetype] then
          return
        end
        vim.b[bufnr].autoformat = false
        vim.keymap.set({ "n", "x" }, "<leader>cf", function()
          require("conform").format({ bufnr = bufnr, async = true })
        end, { buffer = bufnr, desc = "Format SQL asynchronously" })
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = { "sql", "mysql", "plsql" },
        callback = function(event)
          configure_buffer(event.buf)
        end,
      })
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        configure_buffer(bufnr)
      end
    end,
    opts = function(_, opts)
      -- Disable SQLFluff linting while keeping other filetypes' linters.
      for filetype in pairs(sql_filetypes) do
        opts.linters_by_ft[filetype] = vim.tbl_filter(function(name)
          return name ~= "sqlfluff"
        end, opts.linters_by_ft[filetype] or {})
      end
    end,
  },
}
