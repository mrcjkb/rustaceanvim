local M = {}

---@param params { textDocument: lsp_text_document, range: lsp_range }
---@return { textDocument: lsp_text_document, ranges: lsp_range[] }
local function modify_params(params)
  local range = params.range
  params.range = nil
  ---@diagnostic disable-next-line: inject-field
  params.ranges = { range }
  ---@diagnostic disable-next-line: return-type-mismatch
  return params
end

---@param client_id integer
---@return string
local function offset_encoding(client_id)
  local client = vim.lsp.get_client_by_id(client_id)
  return client and client.offset_encoding or 'utf-8'
end

local function handler(_, result, ctx)
  vim.lsp.util.apply_text_edits(result, ctx.bufnr, offset_encoding(ctx.client_id))
end

local ra = require('rustaceanvim.rust_analyzer')

--- Sends the request to rust-analyzer to get the TextEdits to join the lines
--- under the cursor and applies them (for use in visual mode)
function M.join_lines_visual()
  local client = ra.find_active_rustaceanvim_client()
  if not client then
    return
  end
  local params = modify_params(vim.lsp.util.make_given_range_params(nil, nil, 0, client.offset_encoding or 'utf-8'))
  ra.buf_request(0, 'experimental/joinLines', params, handler)
end

--- Sends the request to rust-analyzer to get the TextEdits to join the lines
--- under the cursor and applies them
function M.join_lines()
  local client = ra.find_active_rustaceanvim_client()
  if not client then
    return
  end
  local params = modify_params(vim.lsp.util.make_range_params(0, client.offset_encoding or 'utf-8'))
  ra.buf_request(0, 'experimental/joinLines', params, handler)
end

return M
