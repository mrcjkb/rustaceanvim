---@mod rustaceanvim.os Utilities for interacting with the operating system

local os = {}

local compat = require('rustaceanvim.compat')

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
    compat.system({ 'open', url }, nil, on_exit)
    return
  end
  if vim.fn.executable('sensible-browser') == 1 then
    compat.system({ 'sensible-browser', url }, nil, on_exit)
    return
  end
  if vim.fn.executable('xdg-open') == 1 then
    compat.system({ 'xdg-open', url }, nil, on_exit)
    return
  end
  local ok, err = pcall(vim.fn['netrw#BrowseX'], url, 0)
  if not ok then
    vim.notify('Could not open external docs. Neither xdg-open, nor netrw found: ' .. err, vim.log.levels.ERROR)
  end
end

---Normalize path for Windows, which is case insensitive
---@param path string
---@return string normalize_path
function os.normalize_path(path)
  if require('rustaceanvim.shell').is_windows() then
    local has_windows_drive_letter = path:match('^%a:')
    if has_windows_drive_letter then
      return path:sub(1, 1):lower() .. path:sub(2)
    end
  end
  return path
end

return os
