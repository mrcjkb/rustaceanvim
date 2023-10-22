local ui = require('rustaceanvim.ui')

local M = {}

---@class MemoryLayoutTable
---@field nodes MemoryLayoutNode[]

---@class MemoryLayoutNode
---@field itemName string
---@field typename string
---@field size integer
---@field offset integer offset relative to parent, 0 for root
---@field alignment integer
---@field parentIdx integer index of the node's parent (0-based index, -1 if root)
---@field childrenStart integer (0-based index, -1 if no children)
---@field childrenLen integer number of children

---@return lsp_range_params

---@type integer | nil
local latest_buf_id = nil

---@param result MemoryLayoutTable
---@return string[]
local function to_lines(result)
  local ret = {}
  -- TODO: Implement rendering
  vim.print(result.nodes)
  return ret
end

local function handler(_, result)
  if not result or not result.nodes then
    vim.notify('No memory layout available', vim.log.levels.INFO)
    return
  end
  ui.delete_buf(latest_buf_id)
  latest_buf_id = vim.api.nvim_create_buf(false, true)
  ui.split(true, latest_buf_id)
  vim.api.nvim_buf_set_name(latest_buf_id, 'memory.layout.rust')
  vim.api.nvim_buf_set_text(latest_buf_id, 0, 0, 0, 0, to_lines(result))
  ui.resize(true, '-25')
end

local rl = require('rustaceanvim.rust_analyzer')
function M.memory_layout()
  rl.buf_request(0, 'rust-analyzer/viewRecursiveMemoryLayout', vim.lsp.util.make_position_params(), handler)
end

return M.memory_layout
