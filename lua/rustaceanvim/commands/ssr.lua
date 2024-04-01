local M = {}

---@param query string
---@param visual_mode boolean
local function get_opts(query, visual_mode)
  local opts = vim.lsp.util.make_position_params()
  local range = (visual_mode and vim.lsp.util.make_given_range_params() or vim.lsp.util.make_range_params()).range
  opts.query = query
  opts.parseOnly = false
  opts.selections = { range }
  return opts
end

local function handler(err, result, ctx)
  if err then
    error('Could not execute request to server: ' .. err.message)
    return
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
  end
end

local rl = require('rustaceanvim.rust_analyzer')

---@param query string | nil
---@param visual_mode boolean
function M.ssr(query, visual_mode)
  if not query then
    vim.ui.input({ prompt = 'Enter query: ' }, function(input)
      query = input
    end)
  end
  if query then
    rl.buf_request(0, 'experimental/ssr', get_opts(query, visual_mode), handler)
  end
end

return M.ssr
