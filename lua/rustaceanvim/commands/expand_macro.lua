local config = require('rustaceanvim.config.internal')
local ui = require('rustaceanvim.ui')

local M = {}

---@type integer | nil
local latest_buf_id = nil

---@class rustaceanvim.RAMacroExpansionResult
---@field name string
---@field expansion string

-- parse the lines from result to get a list of the desirable output
-- Example:
-- // Recursive expansion of the eprintln macro
-- // ============================================

-- {
--   $crate::io::_eprint(std::fmt::Arguments::new_v1(&[], &[std::fmt::ArgumentV1::new(&(err),std::fmt::Display::fmt),]));
-- }
---@param result rustaceanvim.RAMacroExpansionResult
---@return string[]
local function parse_lines(result)
  local ret = {}

  local name = result.name
  local text = '// Recursive expansion of the ' .. name .. ' macro'
  table.insert(ret, '// ' .. string.rep('=', string.len(text) - 3))
  table.insert(ret, text)
  table.insert(ret, '// ' .. string.rep('=', string.len(text) - 3))
  table.insert(ret, '')

  local expansion = result.expansion
  for string in string.gmatch(expansion, '([^\n]+)') do
    table.insert(ret, string)
  end

  return ret
end

---@param lines string[]
---@param direction 'horizontal' | 'vertical'
local function render_split(lines, direction)
  -- check if a buffer with the latest id is already open, if it is then
  -- delete it and continue
  ui.delete_buf(latest_buf_id)

  -- create a new buffer
  latest_buf_id = vim.api.nvim_create_buf(false, true) -- not listed and scratch

  local vertical = direction == 'vertical'
  ui.split(vertical, latest_buf_id)

  -- set filetype to rust for syntax highlighting
  vim.bo[latest_buf_id].filetype = 'rust'
  -- write the expansion content to the buffer
  vim.api.nvim_buf_set_lines(latest_buf_id, 0, 0, false, lines)

  -- make the new buffer smaller
  ui.resize(vertical, vertical and '-25' or '-5')
end

---@param lines string[]
local function render_float(lines)
  local preview_lines = vim.deepcopy(lines)
  table.insert(preview_lines, 1, '---')
  table.insert(preview_lines, 1, '1. Open in split')

  local bufnr, winnr = vim.lsp.util.open_floating_preview(
    preview_lines,
    'rust',
    vim.tbl_extend('keep', config.tools.float_win_config, {
      focus_id = 'ra-expand-macro',
    })
  )

  local function close_float()
    ui.close_win(winnr)
  end

  vim.keymap.set('n', 'q', close_float, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<Esc>', close_float, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_win_get_cursor(winnr)[1]
    if line > 1 then
      return
    end
    close_float()
    render_split(lines, 'vertical')
  end, { buffer = bufnr, noremap = true, silent = true })

  if config.tools.float_win_config.auto_focus then
    vim.api.nvim_set_current_win(winnr)
  end
end

---@param open 'float' | 'horizontal' | 'vertical'
---@return lsp.Handler
local function make_handler(open)
  return function(_, result)
    if result == nil then
      vim.notify('No macro under cursor!', vim.log.levels.INFO)
      return
    end

    local lines = parse_lines(result)
    if open == 'float' then
      render_float(lines)
    elseif open == 'horizontal' then
      render_split(lines, 'horizontal')
    elseif open == 'vertical' then
      render_split(lines, 'vertical')
    end
  end
end

--- Sends the request to rust-analyzer to expand the macro under the cursor
---@param open 'float' | 'horizontal' | 'vertical'
function M.expand_macro(open)
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8')
  ra.buf_request(0, 'rust-analyzer/expandMacro', params, make_handler(open))
end

return M.expand_macro
