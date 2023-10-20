local M = {}

local function handler(err)
  if err then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end
  vim.notify('Cargo workspace reloaded')
end

function M.reload_workspace()
  for _, client in ipairs(vim.lsp.get_clients { name = 'rust-analyzer' }) do
    vim.notify('Reloading Cargo Workspace')
    client.request('rust-analyzer/reloadWorkspace', nil, handler, 0)
  end
end

return M.reload_workspace
