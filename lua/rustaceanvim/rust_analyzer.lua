---@mod rustaceanvim.rust_analyzer Functions for interacting with rust-analyzer

local compat = require('rustaceanvim.compat')

---@class RustAnalyzerClientAdapter
local M = {}

---@param bufnr? number
---@return lsp.Client[]
M.get_active_rustaceanvim_clients = function(bufnr)
  local filter = { name = 'rust-analyzer' }
  if bufnr then
    filter.bufnr = bufnr
  end
  return compat.get_clients(filter)
end

---@param bufnr integer Buffer handle, or 0 for current.
---@param method string LSP method name
---@param params table|nil Parameters to send to the server
---@param handler? lsp-handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
M.buf_request = function(bufnr, method, params, handler)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  for _, client in ipairs(M.get_active_rustaceanvim_clients()) do
    if client.supports_method(method, { bufnr = bufnr }) then
      client.request(method, params, handler, bufnr)
    end
  end
end

---@param method string LSP method name
---@param params table|nil Parameters to send to the server
M.notify = function(method, params)
  for _, client in ipairs(M.get_active_rustaceanvim_clients()) do
    if client.supports_method(method) then
      client.notify(method, params)
    end
  end
end

return M
