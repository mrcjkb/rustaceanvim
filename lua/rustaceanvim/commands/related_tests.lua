local ra = require('rustaceanvim.rust_analyzer')

local M = {}

---@class rustaceanvim.RATestInfo
---@field runnable rustaceanvim.RARunnable

-- The `rust-analyzer/relatedTests` resolves using identifier under cursor,
-- but it is useful to resolve related tests while having cursor in the method.
-- This function will recursively find parent fn and then descend to find child
-- identifier, so that the finding works even if the cursor is inside the
-- function.
---@return lsp.Position|nil
local function find_fn_identifier()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_pos = { math.max(cursor[1] - 1, 0), cursor[2] }

  local node = vim.treesitter.get_node { pos = start_pos }
  while node do
    if node:type() == 'function_item' then
      for child in node:iter_children() do
        if child:type() == 'identifier' then
          local start_row, start_col = child:start()
          return { line = start_row, character = start_col }
        end
      end
    end
    node = node:parent()
  end
  return nil
end

---@param enc string
---@return lsp.TextDocumentPositionParams|nil
local function get_params(enc)
  local pos = find_fn_identifier()
  if pos == nil then
    return
  end

  local default_params = vim.lsp.util.make_position_params(0, enc)
  return vim.tbl_extend('force', default_params, { position = pos })
end

---@param item rustaceanvim.RATestInfo
---@param enc string
local function nav_jump_to_test(item, enc)
  local loc = item.runnable.location
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.lsp.util.show_document(loc, enc, { reuse_win = true, focus = true })
end

---@param enc string
---@return lsp.Handler See |lsp-handler|
local function mk_handler(enc)
  ---@param tests rustaceanvim.RATestInfo[]
  return function(_, tests)
    if #tests == 0 then
      return
    elseif #tests == 1 then
      nav_jump_to_test(tests[1], enc)
      return
    end

    local format_fn = function(item)
      return item.runnable.label
    end

    ---@param item rustaceanvim.RATestInfo | nil
    local on_choice = function(item)
      if item ~= nil then
        nav_jump_to_test(item, enc)
      end
    end

    vim.ui.select(tests, { prompt = 'Tests', kind = 'rust-tools/test', format_item = format_fn }, on_choice)
  end
end

---@return nil
function M.related_tests()
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end

  local enc = clients[1].offset_encoding or 'utf-8'

  local params = get_params(enc)
  if params ~= nil then
    ra.buf_request(0, 'rust-analyzer/relatedTests', params, mk_handler(enc))
  end
end

return M
