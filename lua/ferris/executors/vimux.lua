local shell = require('ferris.shell')

---@type FerrisExecutor
local M = {}

function M.execute_command(command, args, cwd)
  local full_command = shell.chain_commands {
    shell.make_command_from_args('cd', { cwd }),
    shell.make_command_from_args(command, args),
  }

  vim.fn.VimuxRunCommand(full_command)
end

return M
