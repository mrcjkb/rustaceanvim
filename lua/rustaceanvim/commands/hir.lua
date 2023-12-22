local M = {}

local rl = require('rustaceanvim.rust_analyzer')
local ui = require('rustaceanvim.ui')

---@type integer | nil
local latest_buf_id = nil

local function handler(err, result)
  if err then
    vim.notify('viewHir failed' .. result and ': ' .. result or '', vim.log.levels.ERROR)
    return
  end
  if result and result:match('Not inside a function body') then
    vim.notify('viewHir failed: Not inside a function body', vim.log.levels.ERROR)
    return
  elseif type(result) ~= 'string' then
    vim.notify('viewHir failed: ' .. vim.inspect(result), vim.log.levels.ERROR)
  end

  -- check if a buffer with the latest id is already open, if it is then
  -- delete it and continue
  ui.delete_buf(latest_buf_id)

  -- create a new buffer
  latest_buf_id = vim.api.nvim_create_buf(false, true) -- not listed and scratch

  -- split the window to create a new buffer and set it to our window
  ui.split(true, latest_buf_id)

  local lines = vim.split(result, '\n')

  -- set filetype to rust for syntax highlighting
  vim.bo[latest_buf_id].filetype = 'rust'
  -- write the expansion content to the buffer
  vim.api.nvim_buf_set_lines(latest_buf_id, 0, 0, false, lines)
end

function M.hir()
  local position_params = vim.lsp.util.make_position_params(0, nil)
  rl.buf_request(0, 'rust-analyzer/viewHir', position_params, handler)
end

return M.hir
