local M = {}

---@return boolean
function M.is_windows()
  local sysname = vim.uv.os_uname().sysname
  return sysname == 'Windows' or sysname == 'Windows_NT'
end

---@return boolean
function M.is_macos()
  return vim.uv.os_uname().sysname == 'Darwin'
end

---@return boolean
local function is_nushell()
  ---@diagnostic disable-next-line: missing-parameter
  local shell = vim.uv.os_getenv('SHELL')
  local nu = 'nu'
  -- Check if $SHELL ends in "nu"
  return shell ~= nil and shell:sub(-string.len(nu)) == nu
end

---Get a new command which is a chain of all the old commands
---Note that a space is not added at the end of the returned command string
---@param commands string[]
---@return string
function M.chain_commands(commands)
  local separator = M.is_windows() and ' | ' or is_nushell() and ';' or ' && '
  local ret = ''

  for i, value in ipairs(commands) do
    local is_last = i == #commands
    ret = ret .. value

    if not is_last then
      ret = ret .. separator
    end
  end

  return ret
end

---Create a `cd` command for the path
---@param path string
---@return string
function M.make_cd_command(path)
  return ("cd '%s'"):format(path)
end

---@param command string
---@param args string[]
---@return string command
function M.make_command_from_args(command, args)
  local ret = command .. ' '

  for _, value in ipairs(args) do
    ret = ret .. value .. ' '
  end

  return ret
end

return M
