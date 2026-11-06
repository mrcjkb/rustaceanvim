---@diagnostic disable: deprecated
-- TODO: Delete when dropping 0.12 support

local uri = vim.uri

local M = {}

if uri then
  M.uri_from_fname = uri.from_fname
  M.uri_from_buf = uri.from_buf
  M.uri_to_fname = uri.to_fname
else
  M.uri_from_fname = vim.uri_from_fname
  M.uri_from_buf = vim.uri_from_bufnr
  M.uri_to_fname = vim.uri_to_fname
end

return M
