local M = {}

---@class CommandCache
local cache = {
  ---@type RARunnableArgs | nil
  last_debuggable = nil,
  ---@type { choice: integer, runnables: RARunnable[] }
  last_runnable = nil,
  ---@type { choice: integer, runnables: RARunnable[] }
  last_testable = nil,
}

---@param choice integer
---@param runnables RARunnable[]
M.set_last_runnable = function(choice, runnables)
  cache.last_runnable = {
    choice = choice,
    runnables = runnables,
  }
end

---@param choice integer
---@param runnables RARunnable[]
M.set_last_testable = function(choice, runnables)
  cache.last_testable = {
    choice = choice,
    runnables = runnables,
  }
end

---@param args RARunnableArgs
M.set_last_debuggable = function(args)
  cache.last_debuggable = args
end

M.execute_last_debuggable = function()
  local args = cache.last_debuggable
  if args then
    local rt_dap = require('rustaceanvim.dap')
    rt_dap.start(args)
  else
    local debuggables = require('rustaceanvim.commands.debuggables')
    debuggables()
  end
end

M.execute_last_testable = function()
  local action = cache.last_testable
  local runnables = require('rustaceanvim.runnables')
  if action then
    runnables.run_command(action.choice, action.runnables)
  else
    runnables.runnables { tests_only = true }
  end
end

M.execute_last_runnable = function()
  local action = cache.last_runnable
  local runnables = require('rustaceanvim.runnables')
  if action then
    runnables.run_command(action.choice, action.runnables)
  else
    runnables.runnables()
  end
end

return M
