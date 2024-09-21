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

return compat
