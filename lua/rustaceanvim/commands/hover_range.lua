local config = require('rustaceanvim.config.internal')
local lsp_util = vim.lsp.util

local M = {}

---@class rustaceanvim.hover_range.State
local _state = {
  ---@type integer
  winnr = nil,
}

local function close_hover()
  local ui = require('rustaceanvim.ui')
  ui.close_win(_state.winnr)
end

-- Converts a tuple of range coordinates into LSP's position argument
---@param row1 integer
---@param col1 integer
---@param row2 integer
---@param col2 integer
---@return lsp_range
local function make_lsp_position(row1, col1, row2, col2)
  -- Note: vim's lines are 1-indexed, but LSP's are 0-indexed
  return {
    ['start'] = {
      line = row1 - 1,
      character = col1,
    },
    ['end'] = {
      line = row2 - 1,
      character = col2,
    },
  }
end

---@return lsp_range | nil
local function get_visual_selected_range()
  -- Taken from https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
  local p1 = vim.fn.getpos('v')
  if not p1 then
    return nil
  end
  local row1 = p1[2]
  local col1 = p1[3]
  local p2 = vim.api.nvim_win_get_cursor(0)
  local row2 = p2[1]
  local col2 = p2[2]

  if row1 < row2 then
    return make_lsp_position(row1, col1, row2, col2)
  elseif row2 < row1 then
    return make_lsp_position(row2, col2, row1, col1)
  end

  return make_lsp_position(row1, math.min(col1, col2), row1, math.max(col1, col2))
end

---@type lsp.Handler
local function handler(_, result, _)
  if not (result and result.contents) then
    return
  end

  local markdown_lines = lsp_util.convert_input_to_markdown_lines(result.contents, {})

  if vim.tbl_isempty(markdown_lines) then
    return
  end

  local float_win_config = config.tools.float_win_config

  local bufnr, winnr = lsp_util.open_floating_preview(
    markdown_lines,
    'markdown',
    vim.tbl_extend('keep', float_win_config, {
      focusable = true,
      focus_id = 'rust-analyzer-hover-range',
      close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
    })
  )

  vim.api.nvim_create_autocmd('WinEnter', {
    callback = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
    end,
    buffer = bufnr,
  })

  if float_win_config.auto_focus then
    vim.api.nvim_set_current_win(winnr)

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
  end

  if _state.winnr ~= nil then
    return
  end

  -- update the window number here so that we can map escape to close even
  -- when there are no actions, update the rest of the state later
  _state.winnr = winnr
  vim.keymap.set('n', 'q', close_hover, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<Esc>', close_hover, { buffer = bufnr, noremap = true, silent = true })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      _state.winnr = nil
    end,
  })

  -- makes more sense in a dropdown-ish ui
  vim.wo[winnr].cursorline = true

  -- explicitly disable signcolumn
  vim.wo[winnr].signcolumn = 'no'
end

function M.hover_range()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_range_params(0, clients[1].offset_encoding or 'utf-8')
  ---@diagnostic disable-next-line: inject-field
  params.position = get_visual_selected_range()
  params.range = nil
  ra.buf_request(0, 'textDocument/hover', params, handler)
end

return M.hover_range
