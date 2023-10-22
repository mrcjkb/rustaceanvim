local M = {}

---@alias lsp_move_items_params { textDocument: lsp_text_document, range: lsp_range, direction: 'Up' | 'Down' }

---@param up boolean
---@return lsp_move_items_params
local function get_params(up)
  local direction = up and 'Up' or 'Down'
  local params = vim.lsp.util.make_range_params()
  params.direction = direction

  return params
end

-- move it baby
local function handler(_, result, ctx)
  if result == nil or #result == 0 then
    return
  end
  local overrides = require('rustaceanvim.overrides')
  overrides.snippet_text_edits_to_text_edits(result)
  vim.lsp.util.apply_text_edits(result, ctx.bufnr, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
end

local rl = require('rustaceanvim.rust_analyzer')

-- Sends the request to rust-analyzer to move the item and handle the response
function M.move_item(up)
  rl.buf_request(0, 'experimental/moveItem', get_params(up or false), handler)
end

return M.move_item
