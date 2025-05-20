local shell = require('rustaceanvim.shell')

---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, opts)
    local envs = ''
    for k, v in pairs(opts.env) do
      envs = envs .. k .. "='" .. v .. "' "
    end
    local commands = {}
    if cwd then
      table.insert(commands, shell.make_cd_command(cwd))
    end
    table.insert(commands, shell.make_command_from_args(command, args))
    local full_command = shell.chain_commands(commands)
    vim.fn.VimuxRunCommand(envs .. full_command)
  end,
}

return M
