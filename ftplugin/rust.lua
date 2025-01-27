if vim.fn.has('nvim-0.10') ~= 1 then
  vim.notify_once('rustaceanvim requires Neovim 0.10 or above', vim.log.levels.ERROR)
  return
end

---@type rustaceanvim.Config
local config = require('rustaceanvim.config.internal')
local compat = require('rustaceanvim.compat')

if not vim.g.loaded_rustaceanvim then
  require('rustaceanvim.config.check').check_for_lspconfig_conflict(vim.schedule_wrap(function(warn)
    vim.notify_once(warn, vim.log.levels.WARN)
  end))
  vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
    local runnables = require('rustaceanvim.runnables')
    local cached_commands = require('rustaceanvim.cached_commands')
    ---@type rustaceanvim.RARunnable[]
    local ra_runnables = command.arguments
    local runnable = ra_runnables[1]
    local cargo_args = runnable.args.cargoArgs
    if #cargo_args > 0 and vim.startswith(cargo_args[1], 'test') then
      cached_commands.set_last_testable(1, ra_runnables)
    end
    cached_commands.set_last_runnable(1, ra_runnables)
    runnables.run_command(1, ra_runnables)
  end

  vim.lsp.commands['rust-analyzer.gotoLocation'] = function(command, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      compat.show_document(command.arguments[1], client.offset_encoding or 'utf-8')
    end
  end

  vim.lsp.commands['rust-analyzer.showReferences'] = function(_)
    vim.lsp.buf.implementation()
  end

  vim.lsp.commands['rust-analyzer.debugSingle'] = function(command)
    local overrides = require('rustaceanvim.overrides')
    local args = command.arguments[1].args
    overrides.sanitize_command_for_debugging(args.cargoArgs)
    local cached_commands = require('rustaceanvim.cached_commands')
    cached_commands.set_last_debuggable(args)
    local rt_dap = require('rustaceanvim.dap')
    ---@diagnostic disable-next-line: invisible
    rt_dap.start(args)
  end

  local commands = require('rustaceanvim.commands')
  commands.create_rustc_command()
end

vim.g.loaded_rustaceanvim = true

local auto_attach = config.server.auto_attach
if type(auto_attach) == 'function' then
  local bufnr = vim.api.nvim_get_current_buf()
  auto_attach = auto_attach(bufnr)
end

if auto_attach then
  require('rustaceanvim.lsp').start()
end
