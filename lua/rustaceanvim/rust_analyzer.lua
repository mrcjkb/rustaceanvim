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
---@param handler? lsp.Handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
M.buf_request = function(bufnr, method, params, handler)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local client_found = false
  for _, client in ipairs(M.get_active_rustaceanvim_clients()) do
    if client.supports_method(method, { bufnr = bufnr }) then
      client.request(method, params, handler, bufnr)
      client_found = true
    end
  end
  if not client_found then
    local error_msg = 'No rust-analyzer client for ' .. method .. ' attched to buffer ' .. bufnr
    if handler then
      ---@type lsp.HandlerContext
      local ctx = {
        bufnr = bufnr,
        client_id = -1,
        method = method,
      }
      handler({ code = -1, message = error_msg }, nil, ctx)
    else
      vim.notify(error_msg, vim.log.levels.ERROR)
    end
  end
end

---@param method string LSP method name
---@param params table|nil Parameters to send to the server
M.notify = function(method, params)
  local client_found = false
  for _, client in ipairs(M.get_active_rustaceanvim_clients()) do
    if client.supports_method(method) then
      client.notify(method, params)
      client_found = true
    end
  end
  if not client_found then
    vim.notify('No rust-analyzer client found for method: ' .. method, vim.log.levels.ERROR)
  end
end

return M
