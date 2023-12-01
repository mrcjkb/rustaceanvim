local shell = require('rustaceanvim.shell')

---@type RustaceanExecutor
local M = {}

function M.execute_command(command, args, cwd)
  local commands = {}
  if cwd then
    table.insert(commands, shell.make_command_from_args('cd', { cwd }))
  end
  table.insert(commands, shell.make_command_from_args(command, args))
  local full_command = shell.chain_commands(commands)
  vim.fn.VimuxRunCommand(full_command)
end

return M
