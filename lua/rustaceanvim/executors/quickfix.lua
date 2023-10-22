---@type RustaceanExecutor
local M = {}

local function clear_qf()
  vim.fn.setqflist({}, ' ', { title = 'cargo' })
end

local function scroll_qf()
  if vim.bo.buftype ~= 'quickfix' then
    vim.api.nvim_command('cbottom')
  end
end

local function append_qf(line)
  vim.fn.setqflist({}, 'a', { lines = { line } })
  scroll_qf()
end

local function copen()
  vim.cmd('copen')
end

function M.execute_command(command, args, cwd)
  -- open quickfix
  copen()
  -- go back to the previous window
  vim.cmd('wincmd p')
  -- clear the quickfix
  clear_qf()

  -- start compiling
  require('plenary.job')
    :new({
      command = command,
      args = args,
      cwd = cwd,
      on_stdout = function(_, data)
        vim.schedule(function()
          append_qf(data)
        end)
      end,
      on_stderr = function(_, data)
        vim.schedule(function()
          append_qf(data)
        end)
      end,
    })
    :start()
end

return M
