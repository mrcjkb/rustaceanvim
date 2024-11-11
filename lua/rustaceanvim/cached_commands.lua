local M = {}

---@alias rustaceanvim.RARunnablesChoice { choice: integer, runnables: rustaceanvim.RARunnable[] }

---@class rustaceanvim.CommandCache
local cache = {
  ---@type rustaceanvim.RARunnableArgs | nil
  last_debuggable = nil,
  ---@type rustaceanvim.RARunnablesChoice
  last_runnable = nil,
  ---@type rustaceanvim.RARunnablesChoice
  last_testable = nil,
}

---@param choice integer
---@param runnables rustaceanvim.RARunnable[]
M.set_last_runnable = function(choice, runnables)
  cache.last_runnable = {
    choice = choice,
    runnables = runnables,
  }
end

---@param choice integer
---@param runnables rustaceanvim.RARunnable[]
M.set_last_testable = function(choice, runnables)
  cache.last_testable = {
    choice = choice,
    runnables = runnables,
  }
end

---@param args rustaceanvim.RARunnableArgs
M.set_last_debuggable = function(args)
  cache.last_debuggable = args
end

---@param executableArgsOverride? string[]
M.execute_last_debuggable = function(executableArgsOverride)
  local args = cache.last_debuggable
  if args then
    if type(executableArgsOverride) == 'table' and #executableArgsOverride > 0 then
      args.executableArgs = executableArgsOverride
    end
    local rt_dap = require('rustaceanvim.dap')
    ---@diagnostic disable-next-line: invisible
    rt_dap.start(args)
  else
    local debuggables = require('rustaceanvim.commands.debuggables')
    debuggables.debuggables(executableArgsOverride)
  end
end

---@param choice rustaceanvim.RARunnablesChoice
---@param executableArgsOverride? string[]
local function override_executable_args_if_set(choice, executableArgsOverride)
  if type(executableArgsOverride) == 'table' and #executableArgsOverride > 0 then
    choice.runnables[choice.choice].args.executableArgs = executableArgsOverride
  end
end

M.execute_last_testable = function(executableArgsOverride)
  local action = cache.last_testable
  local runnables = require('rustaceanvim.runnables')
  if action then
    override_executable_args_if_set(action, executableArgsOverride)
    runnables.run_command(action.choice, action.runnables)
  else
    runnables.runnables(executableArgsOverride, { tests_only = true })
  end
end

---@param executableArgsOverride? string[]
M.execute_last_runnable = function(executableArgsOverride)
  local action = cache.last_runnable
  local runnables = require('rustaceanvim.runnables')
  if action then
    override_executable_args_if_set(action, executableArgsOverride)
    runnables.run_command(action.choice, action.runnables)
  else
    runnables.runnables(executableArgsOverride)
  end
end

return M
