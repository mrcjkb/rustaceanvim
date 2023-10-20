local lsp = require('ferris.lsp')

vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
  local runnables = require('ferris.runnables')
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
  local overrides = require('ferris.overrides')
  overrides.sanitize_command_for_debugging(command.arguments[1].args.cargoArgs)
  local rt_dap = require('ferris.dap')
  rt_dap.start(command.arguments[1].args)
end

lsp.start()
