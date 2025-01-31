---@type integer | nil
local latest_buf_id = nil

---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, _)
    local shell = require('rustaceanvim.shell')
    local ui = require('rustaceanvim.ui')
    local commands = {}
    if cwd then
      table.insert(commands, shell.make_cd_command(cwd))
    end
    table.insert(commands, shell.make_command_from_args(command, args))
    local full_command = shell.chain_commands(commands)

    -- check if a buffer with the latest id is already open, if it is then
    -- delete it and continue
    ui.delete_buf(latest_buf_id)

    -- create the new buffer
    latest_buf_id = vim.api.nvim_create_buf(false, true)

    -- split the window to create a new buffer and set it to our window
    ui.split(false, latest_buf_id)

    -- make the new buffer smaller
    ui.resize(false, '-5')

    -- close the buffer when escape is pressed :)
    vim.keymap.set('n', '<Esc>', '<CMD>q<CR>', { buffer = latest_buf_id, noremap = true })

    -- TODO(0.11): Replace with vim.fn.jobstart(full_command, { term = true })
    -- run the command
    ---@diagnostic disable-next-line: deprecated
    if type(vim.fn.termopen) == 'function' then
      ---@diagnostic disable-next-line: deprecated
      vim.fn.termopen(full_command)
    else
      vim.fn.jobstart(full_command, { term = true })
    end

    -- when the buffer is closed, set the latest buf id to nil else there are
    -- some edge cases with the id being sit but a buffer not being open
    local function onDetach(_, _)
      latest_buf_id = nil
    end
    vim.api.nvim_buf_attach(latest_buf_id, false, { on_detach = onDetach })
  end,
}

return M
