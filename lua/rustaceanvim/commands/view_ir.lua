local M = {}

local rl = require('rustaceanvim.rust_analyzer')
local ui = require('rustaceanvim.ui')

---@type integer | nil
local latest_buf_id = nil

---@alias rustaceanvim.ir.level 'Hir' | 'Mir'

local function handler(level, err, result)
  local requestType = 'view' .. level
  if err then
    vim.notify(requestType .. ' failed' .. (result and ': ' .. result or vim.inspect(err)), vim.log.levels.ERROR)
    return
  end
  if result and result:match('Not inside a function body') then
    vim.notify(requestType .. ' failed: Not inside a function body', vim.log.levels.ERROR)
    return
  elseif type(result) ~= 'string' then
    vim.notify(requestType .. ' failed: ' .. vim.inspect(result), vim.log.levels.ERROR)
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

---@param level rustaceanvim.ir.level
function M.viewIR(level)
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local position_params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8')
  rl.buf_request(0, 'rust-analyzer/view' .. level, position_params, function(...)
    return handler(level, ...)
  end)
end

return M.viewIR
