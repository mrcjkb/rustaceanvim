local config = require('rustaceanvim.config.internal')

local M = {}

local _ran_once = false

---@param result RustAnalyzerInitializedStatusInternal
function M.handler(_, result)
  if result.quiescent and not _ran_once then
    if config.tools.on_initialized then
      config.tools.on_initialized(result)
    end
    _ran_once = true
  end
end

return M
