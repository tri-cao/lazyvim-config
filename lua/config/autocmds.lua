-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Opening a window (e.g. the explorer, or a split) pushes every other window around, and closing it
-- does not give them their old size back. Remember the layout from just before a window opened, and
-- put every window back to those sizes once the opened window(s) are closed again.
--
-- `latest` is the most recent settled layout. A "burst" is a group of windows opened together,
-- stored with the `latest` layout from right before they appeared (its `baseline`).
local SETTLE_MS = 200 -- how long the layout must be quiet before it counts as settled
local bursts = {}
local timer = assert(vim.uv.new_timer())

-- Terminals (e.g. the snacks terminal) manage their own split; tracking them breaks toggling.
local function is_terminal(win)
  local buf = vim.api.nvim_win_get_buf(win)
  return vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "snacks_terminal"
end

local function snapshot()
  local layout = { wins = {}, ids = {} }
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" and not is_terminal(win) then
      layout.wins[#layout.wins + 1] = {
        win = win,
        width = vim.api.nvim_win_get_width(win),
        height = vim.api.nvim_win_get_height(win),
      }
      layout.ids[win] = true
    end
  end
  return layout
end

local latest = snapshot()

-- Every layout change restarts the timer, so `latest` only updates once things have gone quiet.
local function settle_later()
  timer:stop()
  timer:start(
    SETTLE_MS,
    0,
    vim.schedule_wrap(function()
      latest = snapshot()
    end)
  )
end

local function restore(layout)
  -- Resizing one window shifts its neighbours, so repeat until nothing changes (at most 3 passes).
  for _ = 1, 3 do
    local changed = false
    for _, size in ipairs(layout.wins) do
      local win = size.win
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
        if vim.api.nvim_win_get_width(win) ~= size.width then
          changed = pcall(vim.api.nvim_win_set_width, win, size.width) or changed
        end
        if vim.api.nvim_win_get_height(win) ~= size.height then
          changed = pcall(vim.api.nvim_win_set_height, win, size.height) or changed
        end
      end
    end
    if not changed then
      break
    end
  end
  settle_later()
end

local function in_burst(win)
  for _, burst in ipairs(bursts) do
    if burst.wins[win] then
      return true
    end
  end
  return false
end

local group = vim.api.nvim_create_augroup("restore_win_sizes", { clear = true })

vim.api.nvim_create_autocmd("WinNew", {
  group = group,
  callback = vim.schedule_wrap(function()
    local fresh = {}
    for _, win in ipairs(snapshot().wins) do
      if not latest.ids[win.win] and not in_burst(win.win) then
        fresh[#fresh + 1] = win.win
      end
    end
    if #fresh > 0 then
      local burst = bursts[#bursts]
      if not (burst and vim.uv.now() - burst.time < SETTLE_MS) then
        burst = { baseline = latest, wins = {} }
        bursts[#bursts + 1] = burst
      end
      burst.time = vim.uv.now()
      for _, win in ipairs(fresh) do
        burst.wins[win] = true
      end
    end
    settle_later()
  end),
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = group,
  callback = function(ev)
    local closed = tonumber(ev.match)
    for index, burst in ipairs(bursts) do
      if burst.wins[closed] then
        burst.wins[closed] = nil
        if next(burst.wins) == nil then
          table.remove(bursts, index)
          vim.schedule(function()
            restore(burst.baseline)
          end)
        end
        break
      end
    end
    settle_later()
  end,
})

-- Also remember sizes the user changes by hand (mouse drag, :resize).
vim.api.nvim_create_autocmd("WinResized", { group = group, callback = settle_later })
