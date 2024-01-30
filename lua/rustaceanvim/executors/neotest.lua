local trans = require('rustaceanvim.neotest.trans')

---@type RustaceanTestExecutor
---@diagnostic disable-next-line: missing-fields
local M = {}

---@param opts RustaceanTestExecutorOpts
M.execute_command = function(_, _, _, opts)
  ---@type RustaceanTestExecutorOpts
  opts = vim.tbl_deep_extend('force', { bufnr = 0 }, opts or {})
  if type(opts.runnable) ~= 'table' then
    vim.notify('rustaceanvim neotest executor called without a runnable. This is a bug!', vim.log.levels.ERROR)
  end
  local file = vim.api.nvim_buf_get_name(opts.bufnr)
  local pos_id = trans.get_position_id(file, opts.runnable)
  ---@diagnostic disable-next-line: undefined-field
  require('neotest').run.run(pos_id)
end

return M
