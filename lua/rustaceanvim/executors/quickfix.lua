local function clear_qf()
  vim.fn.setqflist({}, ' ', { title = 'cargo' })
end

local function scroll_qf()
  if vim.bo.buftype ~= 'quickfix' then
    vim.api.nvim_command('cbottom')
  end
end

---@param lines string[]
local function append_qf(lines)
  vim.fn.setqflist({}, 'a', { lines = lines })
  scroll_qf()
end

local function copen()
  vim.cmd('copen')
end

---@type rustaceanvim.Executor
local M = {
  execute_command = function(command, args, cwd, _)
    -- open quickfix
    copen()
    -- go back to the previous window
    vim.cmd.wincmd('p')
    -- clear the quickfix
    clear_qf()

    -- start compiling
    local cmd = vim.list_extend({ command }, args)
    vim.system(
      cmd,
      cwd and { cwd = cwd } or {},
      vim.schedule_wrap(function(sc)
        ---@cast sc vim.SystemCompleted
        local data = ([[
%s
%s
]]):format(sc.stdout or '', sc.stderr or '')
        append_qf(vim.split(data, '\n'))
      end)
    )
  end,
}

return M
