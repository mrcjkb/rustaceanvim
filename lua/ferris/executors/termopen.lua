---@type FerrisExecutor
local M = {}

---@type integer | nil
local latest_buf_id = nil

function M.execute_command(command, args, cwd)
  local shell = require('ferris.shell')
  local ui = require('ferris.ui')
  local full_command = shell.chain_commands {
    shell.make_command_from_args('cd', { cwd }),
    shell.make_command_from_args(command, args),
  }

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
  vim.api.nvim_buf_set_keymap(latest_buf_id, 'n', '<Esc>', ':q<CR>', { noremap = true })

  -- run the command
  vim.fn.termopen(full_command)

  -- when the buffer is closed, set the latest buf id to nil else there are
  -- some edge cases with the id being sit but a buffer not being open
  local function onDetach(_, _)
    latest_buf_id = nil
  end
  vim.api.nvim_buf_attach(latest_buf_id, false, { on_detach = onDetach })
end

return M
