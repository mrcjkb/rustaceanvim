local M = {}

local function handler(err)
  if err then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.notify('Cargo workspace reloaded')
end

local rl = require('rustaceanvim.rust_analyzer')

function M.reload_workspace()
  vim.notify('Reloading Cargo Workspace')
  rl.any_buf_request('rust-analyzer/reloadWorkspace', nil, handler)
end

return M.reload_workspace
