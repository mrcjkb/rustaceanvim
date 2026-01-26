local M = {}

local rl = require('rustaceanvim.rust_analyzer')

---@param opts? { silent?: boolean }
function M.reload_workspace(opts)
  opts = opts or {}
  local function handler(err)
    if err then
      vim.notify(tostring(err), vim.log.levels.ERROR)
      return
    end
    if not opts.silent then
      vim.notify('Cargo workspace reloaded')
    end
  end
  if not opts.silent then
    vim.notify('Reloading Cargo Workspace')
  end
  rl.any_buf_request('rust-analyzer/reloadWorkspace', nil, handler)
end

return M.reload_workspace
