local ui = require('rustaceanvim.ui')

local M = {}

---@type integer | nil
local latest_buf_id = nil

local function parse_lines(result)
  local ret = {}

  for line in string.gmatch(result, '([^\n]+)') do
    table.insert(ret, line)
  end

  return ret
end

local function handler(_, result)
  ui.delete_buf(latest_buf_id)
  latest_buf_id = vim.api.nvim_create_buf(false, true)
  ui.split(true, latest_buf_id)
  vim.api.nvim_buf_set_name(latest_buf_id, 'syntax.rust')
  vim.api.nvim_buf_set_text(latest_buf_id, 0, 0, 0, 0, parse_lines(result))
  ui.resize(true, '-25')
end

function M.syntax_tree()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_range_params(0, clients[1].offset_encoding or 'utf-8')
  ra.buf_request(0, 'rust-analyzer/syntaxTree', params, handler)
end

return M.syntax_tree
