local config = require('ferris.config.internal')

local M = {}

function M.handler(_, result)
  if result.quiescent and not M.ran_once then
    if config.tools.on_initialized then
      config.tools.on_initialized(result)
    end
    M.ran_once = true
  end
end

return M
