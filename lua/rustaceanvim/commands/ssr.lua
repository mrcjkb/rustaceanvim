local M = {}

local ui = require('rustaceanvim.ui')

---@param query string
---@param is_range boolean
local function get_opts(query, is_range)
  local params = vim.lsp.util.make_position_params()
  params.query = query
  params.parseOnly = false
  if is_range then
    params.selections = { vim.print(ui.get_visual_selected_range()) }
  else
    params.selections = {}
  end
  return params
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
---@param is_range boolean
function M.ssr(query, is_range)
  if not query then
    vim.ui.input({ prompt = 'Enter query: ' }, function(input)
      query = input
    end)
  end

  if query then
    rl.buf_request(0, 'experimental/ssr', get_opts(query, is_range), handler)
  end
end

return M.ssr
