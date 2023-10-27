local M = {}

---@class CommandCache
local cache = {
  ---@type RADebuggableArgs | nil
  last_debuggable = nil,
  ---@type { choice: integer, runnable: RARunnable }
  last_runnable = nil,
}

---@param choice integer
---@param runnable RARunnable
M.set_last_runnable = function(choice, runnable)
  cache.last_runnable = { choice, runnable }
end

---@param args RADebuggableArgs
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

M.execute_last_runnable = function()
  local action = cache.last_runnable
  local runnables = require('rustaceanvim.runnables')
  if action then
    runnables.run_command(action.choice, action.runnable)
  else
    runnables.runnables()
  end
end

return M
