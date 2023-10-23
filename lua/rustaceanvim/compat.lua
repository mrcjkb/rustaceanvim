---@diagnostic disable: deprecated
---@mod rustaceanvim.compat Functions for backward compatibility with older Neovim versions

local M = {}

M.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

M.uv = vim.uv or vim.loop

return M
