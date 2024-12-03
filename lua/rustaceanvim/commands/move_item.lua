local M = {}

---@alias lsp_move_items_params { textDocument: lsp_text_document, range: lsp_range, direction: 'Up' | 'Down' }

---@param prev_text_edit rustaceanvim.lsp.TextEdit
---@param text_edit rustaceanvim.lsp.TextEdit
local function text_edit_line_range_diff(prev_text_edit, text_edit)
  return math.max(0, text_edit.range.start.line - prev_text_edit.range['end'].line - 1)
    - (prev_text_edit.range.start.line == text_edit.range.start.line and 1 or 0)
end

---@param text_edits rustaceanvim.lsp.TextEdit[]
local function extract_cursor_position(text_edits)
  local cursor = { text_edits[1].range.start.line }
  local prev_text_edit
  for _, text_edit in ipairs(text_edits) do
    if text_edit.newText and text_edit.insertTextFormat == 2 and not cursor[2] then
      cursor[1] = cursor[1] + (prev_text_edit and text_edit_line_range_diff(prev_text_edit, text_edit) or 0)
      local snippet_pos_start = string.find(text_edit.newText, '%$0')
      local lines = vim.split(string.sub(text_edit.newText, 1, snippet_pos_start), '\n')
      local line_count = #lines
      cursor[1] = cursor[1] + line_count
      if snippet_pos_start then
        local start_offset = line_count == 1 and text_edit.range.start.character or 0
        local last_line_length = #lines[line_count] - 1
        cursor[2] = start_offset + last_line_length
      end
    end
    prev_text_edit = text_edit
  end
  return cursor
end

-- move it baby
---@param text_edits? rustaceanvim.lsp.TextEdit[]
---@param ctx lsp.HandlerContext
local function handler(_, text_edits, ctx)
  if text_edits == nil or #text_edits == 0 then
    return
  end
  local cursor = extract_cursor_position(text_edits)
  local overrides = require('rustaceanvim.overrides')
  overrides.snippet_text_edits_to_text_edits(text_edits)
  vim.lsp.util.apply_text_edits(
    text_edits,
    ctx.bufnr,
    vim.lsp.get_client_by_id(ctx.client_id).offset_encoding or 'utf-8'
  )
  vim.api.nvim_win_set_cursor(0, cursor)
end

-- Sends the request to rust-analyzer to move the item and handle the response
---@param direction 'Up' | 'Down'
function M.move_item(direction)
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_range_params(0, clients[1].offset_encoding or 'utf-8')
  ---@diagnostic disable-next-line: inject-field
  params.direction = direction
  ra.buf_request(0, 'experimental/moveItem', params, handler)
end

return M.move_item
