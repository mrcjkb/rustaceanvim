local config = require('rustaceanvim.config.internal')

local M = {}

local function get_params()
  return {
    textDocument = vim.lsp.util.make_text_document_params(0),
    position = nil, -- get em all
  }
end

---@class RARunnable
---@field args RARunnableArgs
---@field label string

---@class RARunnableArgs
---@field workspaceRoot string
---@field cargoArgs string[]
---@field cargoExtraArgs string[]
---@field executableArgs string[]

---@param result RARunnable
local function get_options(result)
  local option_strings = {}

  for _, runnable in ipairs(result) do
    local str = runnable.label
    table.insert(option_strings, str)
  end

  return option_strings
end

---@alias CargoCmd 'cargo'

---@param choice integer
---@param runnables RARunnable[]
---@return CargoCmd command build command
---@return string[] args
---@return string|nil dir
local function getCommand(choice, runnables)
  local args = runnables[choice].args

  local dir = args.workspaceRoot

  local ret = vim.list_extend({}, args.cargoArgs or {})
  ret = vim.list_extend(ret, args.cargoExtraArgs or {})
  table.insert(ret, '--')
  ret = vim.list_extend(ret, args.executableArgs or {})

  return 'cargo', ret, dir
end

---@param choice integer
---@param runnables RARunnable[]
function M.run_command(choice, runnables)
  -- do nothing if choice is too high or too low
  if not choice or choice < 1 or choice > #runnables then
    return
  end

  local opts = config.tools

  local command, args, cwd = getCommand(choice, runnables)
  if not cwd then
    return
  end

  opts.executor.execute_command(command, args, cwd)
end

---@param result RARunnable
local function handler(_, result)
  if result == nil then
    return
  end
  -- get the choice from the user
  local options = get_options(result)
  vim.ui.select(options, { prompt = 'Runnables', kind = 'rust-tools/runnables' }, function(_, choice)
    ---@cast choice integer
    M.run_command(choice, result)

    local cached_commands = require('rustaceanvim.cached_commands')
    cached_commands.set_last_runnable(choice, result)
  end)
end

-- Sends the request to rust-analyzer to get the runnables and handles them
function M.runnables()
  vim.lsp.buf_request(0, 'experimental/runnables', get_params(), handler)
end

return M
