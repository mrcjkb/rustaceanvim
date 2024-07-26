local diag_namespace = vim.api.nvim_create_namespace('rustaceanvim')

---@param output string
---@return string | nil
local function get_test_summary(output)
  return output:match('(test result:.*)')
end

---@type rustaceanvim.Executor
---@diagnostic disable-next-line: missing-fields
local M = {}

---@class rustaceanvim.Diagnostic: vim.Diagnostic
---@field test_id string

M.execute_command = function(command, args, cwd, opts)
  ---@type rustaceanvim.ExecutorOpts
  opts = vim.tbl_deep_extend('force', { bufnr = 0 }, opts or {})
  if vim.fn.has('nvim-0.10.0') ~= 1 then
    vim.schedule(function()
      vim.notify_once("the 'background' executor is not recommended for Neovim < 0.10.", vim.log.levels.WARN)
    end)
    return
  end

  vim.diagnostic.reset(diag_namespace, opts.bufnr)
  local is_single_test = args[1] == 'test'
  local notify_prefix = (is_single_test and 'test ' or 'tests ')
  local cmd = vim.list_extend({ command }, args)
  local fname = vim.api.nvim_buf_get_name(opts.bufnr)
  vim.system(cmd, { cwd = cwd }, function(sc)
    ---@cast sc vim.SystemCompleted
    if sc.code == 0 then
      local summary = get_test_summary(sc.stdout or '')
      vim.schedule(function()
        vim.notify(summary and summary or (notify_prefix .. 'passed!'), vim.log.levels.INFO)
      end)
      return
    end
    local output = (sc.stderr or '') .. '\n' .. (sc.stdout or '')
    local diagnostics = require('rustaceanvim.test').parse_diagnostics(fname, output)
    local summary = get_test_summary(sc.stdout or '')
    vim.schedule(function()
      vim.diagnostic.set(diag_namespace, opts.bufnr, diagnostics)
      vim.cmd.redraw()
      vim.notify(summary and summary or (notify_prefix .. 'failed!'), vim.log.levels.ERROR)
    end)
  end)
end

return M
