---@type RustaceanConfig
local config = require('rustaceanvim.config.internal')
local types = require('rustaceanvim.types.internal')
local lsp = require('rustaceanvim.lsp')

if not vim.g.did_rustaceanvim_initialize then
  vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
    local runnables = require('rustaceanvim.runnables')
    local cached_commands = require('rustaceanvim.cached_commands')
    ---@type RARunnable[]
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
      vim.lsp.util.jump_to_location(command.arguments[1], client.offset_encoding)
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
    rt_dap.start(args)
  end

  local commands = require('rustaceanvim.commands')
  commands.create_rustc_command()
end

vim.g.did_rustaceanvim_initialize = true

local auto_attach = types.evaluate(config.server.auto_attach)

if not auto_attach then
  return
end

lsp.start()
