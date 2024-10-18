---@mod rustaceanvim.rust_analyzer Functions for interacting with rust-analyzer

local os = require('rustaceanvim.os')

---@class rustaceanvim.rust-analyzer.ClientAdapter
local M = {}

---@class RustaceanvimFilter
---@field filter? vim.lsp.get_clients.Filter
---@field rustc_target? string Optional cargo target to filter rust-analyzer clients

---@param bufnr number | nil 0 for the current buffer, `nil` for no buffer filter
---@param filter? RustaceanvimFilter
---@return vim.lsp.Client[]
M.get_active_rustaceanvim_clients = function(bufnr, filter)
  ---@type vim.lsp.get_clients.Filter
  local client_filter = vim.tbl_deep_extend('force', filter and filter.filter or {}, {
    name = 'rust-analyzer',
  })
  if bufnr then
    client_filter.bufnr = bufnr
  end
  local clients = vim.lsp.get_clients(client_filter)
  -- If a rustc_target is specified, filter the clients further
  if filter and filter.rustc_target then
    clients = vim.tbl_filter(function(client)
      if client.config and client.config.settings then
        local rust_settings = client.config.settings['rust-analyzer']
        if rust_settings and rust_settings.cargo and rust_settings.cargo.target then
          -- Exclude the client if we ever reach here
          return rust_settings.cargo.target ~= filter.rustc_target
        end
      end
      -- Include the client if we ever reach here
      return true
    end, clients)
  end
  return clients
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
  for _, client in ipairs(M.get_active_rustaceanvim_clients(nil, { filter = { method = method } })) do
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
  for _, client in ipairs(M.get_active_rustaceanvim_clients(bufnr, { filter = { method = method } })) do
    client.request(method, params, handler, bufnr)
    client_found = true
  end
  return client_found
end

---@param file_path string Search for clients with a root_dir matching this file path
---@param method string LSP method name
---@return vim.lsp.Client|nil
M.get_client_for_file = function(file_path, method)
  for _, client in ipairs(M.get_active_rustaceanvim_clients(nil, { filter = { method = method } })) do
    local root_dir = client.config.root_dir
    if root_dir and vim.startswith(os.normalize_path_on_windows(file_path), root_dir) then
      return client
    end
  end
end
---@param method string LSP method name
---@param params table|nil Parameters to send to the server
M.notify = function(method, params)
  local client_found = false
  for _, client in ipairs(M.get_active_rustaceanvim_clients(0, { filter = { method = method } })) do
    client.notify(method, params)
    client_found = true
  end
  if not client_found then
    vim.notify('No rust-analyzer client found for method: ' .. method, vim.log.levels.ERROR)
  end
end

return M
