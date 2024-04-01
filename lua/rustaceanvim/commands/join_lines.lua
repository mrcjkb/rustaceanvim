local M = {}

---@alias lsp_join_lines_params { textDocument: lsp_text_document, ranges: lsp_range[] }

---@param visual_mode boolean
---@return lsp_join_lines_params
local function get_params(visual_mode)
  local params = visual_mode and vim.lsp.util.make_given_range_params() or vim.lsp.util.make_range_params()
  local range = params.range

  params.range = nil
  params.ranges = { range }

  return params
end

local function handler(_, result, ctx)
  vim.lsp.util.apply_text_edits(result, ctx.bufnr, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
end

local rl = require('rustaceanvim.rust_analyzer')

--- Sends the request to rust-analyzer to get the TextEdits to join the lines
--- under the cursor and applies them
---@param visual_mode boolean
function M.join_lines(visual_mode)
  rl.buf_request(0, 'experimental/joinLines', get_params(visual_mode), handler)
end

return M.join_lines
