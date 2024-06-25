local config = require('rustaceanvim.config.internal')

local M = {}

---@type { [integer]: boolean }
local _ran_once = {}

---@param result RustAnalyzerInitializedStatusInternal
function M.handler(_, result, ctx, _)
  -- quiescent means the full set of results is ready.
  if not result.quiescent or _ran_once[ctx.client_id] then
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
    config.tools.on_initialized(result)
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
