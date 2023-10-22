---@type RustaceanConfig
local config = require('rustaceanvim.config.internal')
local types = require('rustaceanvim.types.internal')
local lsp = require('rustaceanvim.lsp')

local auto_attach = types.evaluate(config.server.auto_attach)
if not auto_attach then
  return
end

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
  local runnables = require('rustaceanvim.runnables')
  runnables.run_command(1, command.arguments)
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
  overrides.sanitize_command_for_debugging(command.arguments[1].args.cargoArgs)
  local rt_dap = require('rustaceanvim.dap')
  rt_dap.start(command.arguments[1].args)
end

lsp.start()
