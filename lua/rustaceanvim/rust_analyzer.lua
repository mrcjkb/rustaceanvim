---@mod rustaceanvim.rust_analyzer Functions for interacting with rust-analyzer

local os = require('rustaceanvim.os')

---@class rustaceanvim.rust-analyzer.ClientAdapter
local M = {}

--- Default target value for rustc when no specific target is provided.
--- Used as a fallback to let rustc determine the appropriate target based on the OS.
DEFAULT_RUSTC_TARGET = 'OS'

---Local rustc targets cache
local rustc_targets_cache = nil

M.load_os_rustc_target = function()
  vim.system({ 'rustc', '-Vv' }, { text = true }, function(result)
    if result.code == 0 then
      for line in result.stdout:gmatch('[^\r\n]+') do
        local host = line:match('^host:%s*(.+)$')
        if host then
          M.os_rustc_target = host
          break
        end
      end
    end
  end)
end

---Handles retrieving rustc target architectures and running the passed in callback
---to perform certain actions using the retrieved targets.
---@param callback fun(targets: string[])
M.with_rustc_target_architectures = function(callback)
  if rustc_targets_cache then
    return callback(rustc_targets_cache)
  end
  vim.system(
    { 'rustc', '--print', 'target-list' },
    { text = true },
    ---@param result vim.SystemCompleted
    function(result)
      if result.code ~= 0 then
        error('Failed to retrieve rustc targets: ' .. result.stderr)
      end
      rustc_targets_cache = vim.iter(result.stdout:gmatch('[^\r\n]+')):fold(
        {},
        ---@param acc table<string, boolean>
        ---@param target string
        function(acc, target)
          acc[target] = true
          return acc
        end
      )
      return callback(rustc_targets_cache)
    end
  )
end

---@class rustaceanvim.lsp.get_clients.Filter: vim.lsp.get_clients.Filter
---@field exclude_rustc_target? string Cargo target triple (e.g., 'x86_64-unknown-linux-gnu') to filter rust-analyzer clients

---@param bufnr number | nil 0 for the current buffer, `nil` for no buffer filter
---@param filter? rustaceanvim.lsp.get_clients.Filter
---@return vim.lsp.Client[]
M.get_active_rustaceanvim_clients = function(bufnr, filter)
  ---@type vim.lsp.get_clients.Filter
  local client_filter = vim.tbl_deep_extend('force', filter or {}, {
    name = 'rust-analyzer',
  })
  if bufnr then
    client_filter.bufnr = bufnr
  end
  local clients = vim.lsp.get_clients(client_filter)
  if filter and filter.exclude_rustc_target then
    clients = vim.tbl_filter(function(client)
      local cargo_target = vim.tbl_get(client, 'config', 'settings', 'rust-analyzer', 'cargo', 'target')
      if filter.exclude_rustc_target == DEFAULT_RUSTC_TARGET and cargo_target == nil then
        return false
      end
      return cargo_target ~= filter.exclude_rustc_target
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

---@param file_path string Search for clients with a root_dir matching this file path
---@param method string LSP method name
---@return vim.lsp.Client|nil
M.get_client_for_file = function(file_path, method)
  for _, client in ipairs(M.get_active_rustaceanvim_clients(nil, { method = method })) do
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
  for _, client in ipairs(M.get_active_rustaceanvim_clients(0, { method = method })) do
    client.notify(method, params)
    client_found = true
  end
  if not client_found then
    vim.notify('No rust-analyzer client found for method: ' .. method, vim.log.levels.ERROR)
  end
end

return M
