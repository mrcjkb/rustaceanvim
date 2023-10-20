---@class RustAnalyzerClientAdapter
local M = {}

---@param bufnr integer Buffer handle, or 0 for current.
---@param method string LSP method name
---@param params table|nil Parameters to send to the server
---@param handler? lsp-handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
M.buf_request = function(bufnr, method, params, handler)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  for _, client in ipairs(vim.lsp.get_clients { name = 'rust-analyzer' }) do
    if client.supports_method(method, { bufnr = bufnr }) then
      client.request(method, params, handler, bufnr)
    end
  end
end

return M
