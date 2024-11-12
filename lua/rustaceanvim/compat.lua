---@diagnostic disable: deprecated, duplicate-doc-alias

---@mod rustaceanvim.compat compativility layer for
---API calls that are deprecated or removed in nvim nightly

local compat = {}

---@return lsp.Diagnostic[]
function compat.get_line_diagnostics()
  if vim.lsp.diagnostic.from then
    local opts = {
      lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
    }
    return vim.lsp.diagnostic.from(vim.diagnostic.get(0, opts))
  end
  ---@diagnostic disable-next-line: deprecated
  return vim.lsp.diagnostic.get_line_diagnostics()
end

---@param location lsp.Location|lsp.LocationLink
---@param offset_encoding 'utf-8'|'utf-16'|'utf-32'?
---@return boolean `true` if the jump succeeded
function compat.show_document(location, offset_encoding)
  local show_document = vim.lsp.show_document
  if not show_document then
    return vim.lsp.util.jump_to_location(location, offset_encoding)
  end
  return show_document(location, offset_encoding, { focus = true })
end

return compat
