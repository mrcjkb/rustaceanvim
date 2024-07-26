---@mod rustaceanvim.os Utilities for interacting with the operating system

local os = {}

local shell = require('rustaceanvim.shell')

---@param url string
function os.open_url(url)
  ---@param obj table
  local function on_exit(obj)
    if obj.code ~= 0 then
      vim.schedule(function()
        vim.notify('Could not open URL: ' .. url, vim.log.levels.ERROR)
      end)
    end
  end

  if vim.fn.has('mac') == 1 then
    vim.system({ 'open', url }, nil, on_exit)
    return
  end
  if vim.fn.executable('sensible-browser') == 1 then
    vim.system({ 'sensible-browser', url }, nil, on_exit)
    return
  end
  if vim.fn.executable('xdg-open') == 1 then
    vim.system({ 'xdg-open', url }, nil, on_exit)
    return
  end
  local ok, err = pcall(vim.fn['netrw#BrowseX'], url, 0)
  if not ok then
    vim.notify('Could not open external docs. Neither xdg-open, nor netrw found: ' .. err, vim.log.levels.ERROR)
  end
end

---@param path string
---@return boolean
local function starts_with_windows_drive_letter(path)
  return path:match('^%a:') ~= nil
end

---Normalize path for Windows, which is case insensitive
---@param path string
---@return string normalized_path
function os.normalize_path_on_windows(path)
  if shell.is_windows() and starts_with_windows_drive_letter(path) then
    return path:sub(1, 1):lower() .. path:sub(2):gsub('/+', '\\')
  end
  return path
end

---@param path string
---@return boolean
function os.is_valid_file_path(path)
  local normalized_path = vim.fs.normalize(path, { expand_env = false })
  if shell.is_windows() then
    return starts_with_windows_drive_letter(normalized_path)
  end
  return vim.startswith(normalized_path, '/')
end

---Read the content of a file
---@param filename string
---@return string|nil content
function os.read_file(filename)
  local content
  local f = io.open(filename, 'r')
  if f then
    content = f:read('*a')
    f:close()
  end
  return content
end

return os
