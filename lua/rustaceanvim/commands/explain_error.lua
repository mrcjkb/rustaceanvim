local config = require('rustaceanvim.config.internal')
local M = {}

local compat = require('rustaceanvim.compat')

local rustc = 'rustc'

function M.explain_error()
  if vim.fn.executable(rustc) ~= 1 then
    vim.notify('rustc is needed to explain errors.', vim.log.levels.ERROR)
    return
  end

  local diagnostics = vim.tbl_filter(function(diagnostic)
    return diagnostic.code ~= nil and diagnostic.source == 'rustc'
  end, vim.diagnostic.get(0, {}))
  if #diagnostics == 0 then
    vim.notify('No explainnable errors found.', vim.log.levels.INFO)
    return
  end
  local win_id = vim.api.nvim_get_current_win()
  local opts = {
    cursor_position = vim.api.nvim_win_get_cursor(win_id),
    severity = vim.diagnostic.severity.ERROR,
    wrap = true,
  }
  local found = false
  local diagnostic
  local pos_map = {}
  local pos_id = 1
  repeat
    diagnostic = vim.diagnostic.get_next(opts)
    pos_map[pos_id] = diagnostic
    if diagnostic == nil then
      break
    end
    found = diagnostic.code ~= nil and diagnostic.source == 'rustc'
    local pos = { diagnostic.lnum, diagnostic.col }
    pos_id = pos[1] + pos[2]
    opts.cursor_position = pos
    local searched_all = pos_map[pos_id] ~= nil
  until diagnostic == nil or found or searched_all
  if not found then
    return
  end

  ---@param sc vim.SystemCompleted
  local function handler(sc)
    if sc.code ~= 0 or not sc.stdout then
      vim.notify('Error calling rustc --explain' .. (sc.stderr and ': ' .. sc.stderr or ''), vim.log.levels.ERROR)
      return
    end
    local output = sc.stdout:gsub('```', '```rust', 1)
    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(output, {})
    vim.schedule(function()
      local _, winnr = vim.lsp.util.open_floating_preview(
        markdown_lines,
        'markdown',
        vim.tbl_extend('keep', config.tools.hover_actions, {
          focus = false,
          focusable = true,
          focus_id = 'rustc-explain-error',
          close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
        })
      )

      if config.tools.hover_actions.auto_focus then
        vim.api.nvim_set_current_win(winnr)
      end
    end)
  end

  -- Save position in the window's jumplist
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(win_id, { diagnostic.lnum + 1, diagnostic.col })
  -- Open folds under the cursor
  vim.cmd('normal! zv')
  compat.system({ rustc, '--explain', diagnostic.code }, nil, vim.schedule_wrap(handler))
end

return M.explain_error
