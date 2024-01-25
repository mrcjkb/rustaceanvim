local config = require('rustaceanvim.config.internal')

local M = {}

---@return { textDocument: lsp_text_document, position: nil }
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

---@param result RARunnable[]
---@param executableArgsOverride? string[]
local function get_options(result, executableArgsOverride)
  local option_strings = {}

  for _, runnable in ipairs(result) do
    local str = runnable.label .. (executableArgsOverride and ' -- ' .. table.concat(executableArgsOverride, ' ') or '')
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

---@param executableArgsOverride? string[]
---@return fun(_, result: RARunnable[])
local function mk_handler(executableArgsOverride)
  ---@param runnables RARunnable[]
  return function(_, runnables)
    if runnables == nil then
      return
    end
    if type(executableArgsOverride) == 'table' and #executableArgsOverride > 0 then
      local unique_runnables = {}
      for _, runnable in pairs(runnables) do
        runnable.args.executableArgs = executableArgsOverride
        unique_runnables[vim.inspect(runnable)] = runnable
      end
      runnables = vim.tbl_values(unique_runnables)
    end
    -- get the choice from the user
    local options = get_options(runnables, executableArgsOverride)
    vim.ui.select(options, { prompt = 'Runnables', kind = 'rust-tools/runnables' }, function(_, choice)
      ---@cast choice integer
      M.run_command(choice, runnables)

      local cached_commands = require('rustaceanvim.cached_commands')
      cached_commands.set_last_runnable(choice, runnables)
    end)
  end
end

---Sends the request to rust-analyzer to get the runnables and handles them
---@param executableArgsOverride? string[]
function M.runnables(executableArgsOverride)
  vim.lsp.buf_request(0, 'experimental/runnables', get_params(), mk_handler(executableArgsOverride))
end

return M
