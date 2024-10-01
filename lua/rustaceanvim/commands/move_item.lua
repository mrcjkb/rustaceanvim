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

---@param text_edits rustaceanvim.lsp.TextEdit[]
local function extract_cursor_position(text_edits)
  local cursor = { text_edits[1].range.start.line }
  local prev_text_edit
  for _, text_edit in ipairs(text_edits) do
    if text_edit.newText and text_edit.insertTextFormat == 2 then
      if not cursor[2] then
        if prev_text_edit then
          cursor[1] = cursor[1]
            + math.max(0, text_edit.range.start.line - prev_text_edit.range['end'].line - 1)
            - (prev_text_edit.range.start.line == text_edit.range.start.line and 1 or 0)
        end
        local pos_start = string.find(text_edit.newText, '%$0')
        local lines = vim.split(string.sub(text_edit.newText, 1, pos_start), '\n')
        local total_lines = #lines
        cursor[1] = cursor[1] + total_lines
        if pos_start then
          cursor[2] = (total_lines == 1 and text_edit.range.start.character or 0) + #lines[total_lines] - 1
        end
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
  vim.lsp.util.apply_text_edits(text_edits, ctx.bufnr, vim.lsp.get_client_by_id(ctx.client_id).offset_encoding)
  vim.api.nvim_win_set_cursor(0, cursor)
end

local rl = require('rustaceanvim.rust_analyzer')

-- Sends the request to rust-analyzer to move the item and handle the response
function M.move_item(up)
  rl.buf_request(0, 'experimental/moveItem', get_params(up or false), handler)
end

return M.move_item
