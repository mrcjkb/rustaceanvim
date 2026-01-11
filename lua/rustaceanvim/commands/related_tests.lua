local ra = require('rustaceanvim.rust_analyzer')
local rts = require('rustaceanvim.treesitter')

local M = {}

---@class rustaceanvim.RATestInfo
---@field runnable rustaceanvim.RARunnable

---@param offset_encoding string
---@return lsp.TextDocumentPositionParams
local function get_params(offset_encoding)
  local position_params = vim.lsp.util.make_position_params(0, offset_encoding)

  if rts.has_tree_sitter_rust() then
    local fn_identifier_position = rts.find_fn_identifier_position()
    if fn_identifier_position ~= nil then
      position_params.position = fn_identifier_position
    end
  end

  return position_params
end

---@param offset_encoding string
---@return lsp.Handler See |lsp-handler|
local function mk_handler(offset_encoding)
  ---@param tests? rustaceanvim.RATestInfo[]
  return function(_, tests)
    if tests == nil then
      -- this can be nil when LSP has not finished loading
      return
    end

    local test_locations = {}
    for _, test in ipairs(tests) do
      table.insert(test_locations, test.runnable.location)
    end

    if #test_locations == 0 then
      return
    elseif #test_locations == 1 then
      vim.lsp.util.show_document(test_locations[1], offset_encoding, { reuse_win = true, focus = true })
      return
    else
      local quickfix_entries = vim.lsp.util.locations_to_items(test_locations, offset_encoding)
      vim.fn.setqflist({}, ' ', { title = 'related tests', items = quickfix_entries })
      vim.cmd([[ botright copen ]])
    end
  end
end

---@return nil
function M.related_tests()
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end

  local offset_encoding = clients[1].offset_encoding or 'utf-8'

  local params = get_params(offset_encoding)
  ra.buf_request(0, 'rust-analyzer/relatedTests', params, mk_handler(offset_encoding))
end

return M
