-- local lib = require('neotest.lib')
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

local function read_file(path)
  local open_err, file_fd = vim.uv.fs_open(path, 'r', 438)
  assert(not open_err, open_err)
  local stat_err, stat = vim.uv.fs_fstat(file_fd)
  assert(not stat_err, stat_err)
  local read_err, data = vim.uv.fs_read(file_fd, stat.size, 0)
  assert(not read_err, read_err)
  return data
end

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
  vim.system(cmd, { cwd = cwd, env = opts.env }, function(sc)
    ---@cast sc vim.SystemCompleted
    if sc.code == 0 then
      local summary = get_test_summary(sc.stdout or '')
      vim.schedule(function()
        vim.notify(summary and summary or (notify_prefix .. 'passed!'), vim.log.levels.INFO)
      end)
      return
    end
    local output = (sc.stderr or '') .. '\n' .. (sc.stdout or '')
    local diagnostics = {}

    local is_cargo_test = args[1] == 'test'
    if is_cargo_test then
      diagnostics = require('rustaceanvim.test').parse_cargo_test_diagnostics(output, opts.bufnr)
    else
      local junit_xml = read_file((cwd or vim.fn.getcwd()) .. '/target/nextest/rustaceanvim/junit.xml')
      diagnostics = require('rustaceanvim.test').parse_nextest_diagnostics(junit_xml, opts.bufnr)
    end
    local summary = get_test_summary(sc.stdout or '')
    vim.schedule(function()
      vim.diagnostic.set(diag_namespace, opts.bufnr, diagnostics)
      vim.cmd.redraw()
      vim.notify(summary and summary or (notify_prefix .. 'failed!'), vim.log.levels.ERROR)
    end)
  end)
end

return M
