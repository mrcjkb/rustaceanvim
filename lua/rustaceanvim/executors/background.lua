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

---@param path string
---@return boolean success
---@return string content_or_err
local function read_file(path)
  local file_fd, open_err = vim.uv.fs_open(path, 'r', 438)
  if not file_fd or open_err then
    return false, open_err or ('expected file descriptor for ' .. path)
  end
  local stat, stat_err = vim.uv.fs_fstat(file_fd)
  if not stat or stat_err then
    return false, stat_err or ('expected file stats for ' .. path)
  end
  local data, read_err = vim.uv.fs_read(file_fd, stat.size, 0)
  if not data or read_err then
    return false, read_err or ('expected file content for ' .. path)
  end
  return true, data
end

M.execute_command = function(command, args, cwd, opts)
  ---@type rustaceanvim.ExecutorOpts
  opts = vim.tbl_deep_extend('force', { bufnr = 0 }, opts or {})
  ---@cast opts.bufnr integer

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
    local diagnostics
    local is_cargo_test = args[1] == 'test'
    if is_cargo_test then
      diagnostics = require('rustaceanvim.test').parse_cargo_test_diagnostics(output, opts.bufnr)
    else
      local ok, junit_xml_or_err = read_file((cwd or vim.fn.getcwd()) .. '/target/nextest/rustaceanvim/junit.xml')
      if not ok then
        vim.notify('Failed to read junit.xml file: ' .. junit_xml_or_err, vim.log.levels.ERROR)
        return
      end
      diagnostics = require('rustaceanvim.test').parse_nextest_diagnostics(junit_xml_or_err, opts.bufnr)
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
