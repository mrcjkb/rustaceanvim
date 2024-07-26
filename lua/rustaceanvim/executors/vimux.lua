local shell = require('rustaceanvim.shell')

---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, _)
    local commands = {}
    if cwd then
      table.insert(commands, shell.make_cd_command(cwd))
    end
    table.insert(commands, shell.make_command_from_args(command, args))
    local full_command = shell.chain_commands(commands)
    vim.fn.VimuxRunCommand(full_command)
  end,
}

return M
