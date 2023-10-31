---@diagnostic disable: deprecated, duplicate-doc-field
---@mod rustaceanvim.compat Functions for backward compatibility with older Neovim versions

local M = {}

M.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

M.uv = vim.uv or vim.loop

--- @class vim.SystemCompleted
--- @field code integer
--- @field signal integer
--- @field stdout? string
--- @field stderr? string

M.system = vim.system
  -- wrapper around vim.fn.system to give it a similar API to vim.system
  or function(cmd, opts, on_exit)
    ---@cast cmd string[]
    ---@cast opts SystemOpts | nil
    ---@cast on_exit fun(sc: vim.SystemCompleted) | nil
    ---@diagnostic disable-next-line: undefined-field
    if opts and opts.cwd then
      local shell = require('rustaceanvim.shell')
      cmd = shell.chain_commands { 'cd ' .. opts.cwd, table.concat(cmd, ' ') }
      ---@cast cmd string
    end

    local output = vim.fn.system(cmd)
    local ok = vim.v.shell_error
    ---@type vim.SystemCompleted
    local systemObj = {
      signal = 0,
      stdout = ok and (output or '') or nil,
      stderr = not ok and (output or '') or nil,
      code = vim.v.shell_error,
    }
    if on_exit then
      on_exit(systemObj)
    end
    return systemObj
  end

M.list_contains = vim.list_contains
  or function(t, value)
    vim.validate { t = { t, 't' } }
    for _, v in ipairs(t) do
      if v == value then
        return true
      end
    end
    return false
  end

return M
