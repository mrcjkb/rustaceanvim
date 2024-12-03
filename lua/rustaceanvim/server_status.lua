local config = require('rustaceanvim.config.internal')

local M = {}

---@type { [integer]: boolean }
local _ran_once = {}

---@param health rustaceanvim.lsp_server_health_status
---@return boolean
local function is_notify_enabled_for(health)
  if health and health == 'ok' then
    return false
  end
  local notify_level = config.server.status_notify_level
  if not notify_level then
    return false
  end
  if notify_level == 'error' then
    return health == 'error'
  end
  return true
end

---@param result rustaceanvim.internal.RAInitializedStatus
---@param ctx lsp.HandlerContext
function M.handler(_, result, ctx, _)
  -- quiescent means the full set of results is ready.
  if not result or not result.quiescent then
    return
  end
  -- notify of LSP errors/warnings
  if is_notify_enabled_for(result.health) then
    local message = ([[
rust-analyzer health status is [%s]:
%s
Run ':RustLsp logFile' for details.
To configure or disable rust-analyzer server status notifications,
see ':h rustaceanvim.lsp.ClientOpts'.
]]):format(result.health, result.message or '[unknown error]')
    vim.notify(message, vim.log.levels.WARN)
  end
  -- deduplicate messages.
  if _ran_once[ctx.client_id] then
    return
  end
  -- rust-analyzer may provide incomplete/empty inlay hints by the time Neovim
  -- calls the `on_attach` callback.
  -- [https://github.com/neovim/neovim/issues/26511]
  -- This workaround forces Neovim to redraw inlay hints if they are enabled,
  -- as soon as rust-analyzer has fully initialized.
  if type(vim.lsp.inlay_hint) == 'table' then
    for _, bufnr in ipairs(vim.lsp.get_buffers_by_client_id(ctx.client_id)) do
      if vim.lsp.inlay_hint.is_enabled { bufnr = bufnr } then
        vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
    end
  end
  -- Load user on_initialized
  if config.tools.on_initialized then
    config.tools.on_initialized(result, ctx.client_id)
  end
  if config.dap.autoload_configurations then
    require('rustaceanvim.commands.debuggables').add_dap_debuggables()
  end
  _ran_once[ctx.client_id] = true
end

---@param client_id integer
function M.reset_client_state(client_id)
  _ran_once[client_id] = false
end

return M
