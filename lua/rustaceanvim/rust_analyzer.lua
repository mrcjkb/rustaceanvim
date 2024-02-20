---@mod rustaceanvim.rust_analyzer Functions for interacting with rust-analyzer

local compat = require('rustaceanvim.compat')
local os = require('rustaceanvim.os')

---@class RustAnalyzerClientAdapter
local M = {}

---@param bufnr number | nil 0 for the current buffer, `nil` for no buffer filter
---@param filter? vim.lsp.get_clients.filter
---@return lsp.Client[]
M.get_active_rustaceanvim_clients = function(bufnr, filter)
  ---@type vim.lsp.get_clients.filter
  filter = vim.tbl_deep_extend('force', filter or {}, {
    name = 'rust-analyzer',
  })
  if bufnr then
    filter.bufnr = bufnr
  end
  return compat.get_clients(filter)
end

---@param method string LSP method name
---@param params table|nil Parameters to send to the server
---@param handler? lsp.Handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
M.any_buf_request = function(method, params, handler)
  local bufnr = vim.api.nvim_get_current_buf()
  local client_found = M.buf_request(bufnr, method, params, handler)
  if client_found then
    return
  end
  -- No buffer found. Try any client.
  for _, client in ipairs(M.get_active_rustaceanvim_clients(nil, { method = method })) do
    client.request(method, params, handler, 0)
  end
end

---@param bufnr integer Buffer handle, or 0 for current.
---@param method string LSP method name
---@param params table|nil Parameters to send to the server
---@param handler? lsp.Handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
---@return boolean client_found
M.buf_request = function(bufnr, method, params, handler)
  if bufnr == nil or bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end
  local client_found = false
  for _, client in ipairs(M.get_active_rustaceanvim_clients(bufnr, { method = method })) do
    client.request(method, params, handler, bufnr)
    client_found = true
  end
  return client_found
end

----@param name string
----@return integer
local function find_buffer_by_name(name)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    if buf_name == name then
      return bufnr
    end
  end
  return 0
end

---@param file_path string Search for clients with a root_dir matching this file path
---@param method string LSP method name
---@param params table|nil Parameters to send to the server
---@param handler? lsp.Handler See |lsp-handler|
---       If nil, follows resolution strategy defined in |lsp-handler-configuration|
M.file_request = function(file_path, method, params, handler)
  local client_found = false
  for _, client in ipairs(M.get_active_rustaceanvim_clients(nil, { method = method })) do
    local root_dir = client.config.root_dir
    if root_dir and vim.startswith(os.normalize_path(file_path), root_dir) then
      local bufnr = find_buffer_by_name(file_path)
      if not params then
        params = {
          textDocument = {
            uri = vim.uri_from_fname(file_path),
          },
          position = nil,
        }
      end
      client.request(method, params, handler, bufnr)
      client_found = true
      if bufnr == -1 then
        return
      end
    end
  end
  if not client_found then
    local error_msg = 'No rust-analyzer client for ' .. method .. ' and file ' .. file_path
    if handler then
      ---@type lsp.HandlerContext
      local ctx = {
        bufnr = -1,
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
  for _, client in ipairs(M.get_active_rustaceanvim_clients(0, { method = method })) do
    client.notify(method, params)
    client_found = true
  end
  if not client_found then
    vim.notify('No rust-analyzer client found for method: ' .. method, vim.log.levels.ERROR)
  end
end

return M
