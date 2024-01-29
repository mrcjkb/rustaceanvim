local M = {}

local ui = require('rustaceanvim.ui')

---@return lsp_range_params
local function get_opts()
  local params = vim.lsp.util.make_range_params()
  params.position = ui.get_visual_selected_range()
  params.range = nil
  return params
end

local rl = require('rustaceanvim.rust_analyzer')

function M.hover_range()
  rl.buf_request(0, 'textDocument/hover', get_opts())
end

return M.hover_range
