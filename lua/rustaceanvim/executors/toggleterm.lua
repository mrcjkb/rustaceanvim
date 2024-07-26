---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, _)
    local ok, term = pcall(require, 'toggleterm.terminal')
    if not ok then
      vim.schedule(function()
        vim.notify('toggleterm not found.', vim.log.levels.ERROR)
      end)
      return
    end

    local shell = require('rustaceanvim.shell')
    term.Terminal
      :new({
        dir = cwd,
        cmd = shell.make_command_from_args(command, args),
        close_on_exit = false,
        on_open = function(t)
          -- enter normal mode
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, true, true), '', true)

          -- set close keymap
          vim.keymap.set('n', 'q', '<CMD>close<CR>', { buffer = t.bufnr, noremap = true })
        end,
      })
      :toggle()
  end,
}

return M
