local M = {}

---@param err lsp.ResponseError?
local function handler(err, _, _)
  if err then
    vim.notify('Error rebuilding proc macros: ' .. vim.inspect(err))
    return
  end
end

local rl = require('rustaceanvim.rust_analyzer')

--- Sends the request to rust-analyzer rebuild proc macros
function M.rebuild_macros()
  rl.any_buf_request('rust-analyzer/rebuildProcMacros', nil, handler)
end

return M.rebuild_macros
