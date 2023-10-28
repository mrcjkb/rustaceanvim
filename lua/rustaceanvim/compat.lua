---@diagnostic disable: deprecated
---@mod rustaceanvim.compat Functions for backward compatibility with older Neovim versions

local M = {}

M.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

M.uv = vim.uv or vim.loop

M.system = vim.system
  -- wrapper around vim.fn.system to give it a similar API as vim.system
  or function(cmd, _, on_exit)
    local output = vim.fn.system(cmd)
    local ok = vim.v.shell_error
    ---@type vim.SystemCompleted
    local systemObj = {
      signal = 0,
      stdout = ok and (output or '') or nil,
      stderr = not ok and (output or '') or nil,
      code = vim.v.shell_error,
    }
    on_exit(systemObj)
    return systemObj
  end

return M
