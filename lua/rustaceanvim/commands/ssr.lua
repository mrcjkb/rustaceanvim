local M = {}

local ra = require('rustaceanvim.rust_analyzer')

---@params table
---@query string
---@param range table
local function modify_params(params, query, range)
  params.query = query
  params.parseOnly = false
  params.selections = { range }
end

local function handler(err, result, ctx)
  if err then
    error('Could not execute request to server: ' .. err.message)
    return
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    vim.lsp.util.apply_workspace_edit(result, client.offset_encoding or 'utf-8')
  end
end

---@param query? string
---@param make_range_params fun(bufnr: integer, offset_encoding: string):{ range: table }
local function ssr(query, make_range_params)
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8')
  local range = make_range_params(0, clients[1].offset_encoding or 'utf-8').range
  if not query then
    vim.ui.input({ prompt = 'Enter query: ' }, function(input)
      query = input
    end)
  end
  modify_params(params, query, range)
  if query then
    ra.buf_request(0, 'experimental/ssr', params, handler)
  end
end

---@param query? string
M.ssr = function(query)
  ssr(query, vim.lsp.util.make_range_params)
end

---@param query string | nil
function M.ssr_visual(query)
  ssr(query, function(winnr, offset_encoding)
    return vim.lsp.util.make_given_range_params(nil, nil, winnr, offset_encoding or 'utf-8')
  end)
end

return M
