local diag_namespace = vim.api.nvim_create_namespace('rustaceanvim')

---@param output string
---@return string | nil
local function get_test_summary(output)
  return output:match('(test result:.*)')
end

---@type RustaceanExecutor
---@diagnostic disable-next-line: missing-fields
local M = {}

---@package
---@param file_name string
---@param output string
---@return vim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
M.parse_diagnostics = function(file_name, output)
  output = output:gsub('\r\n', '\n')
  local lines = vim.split(output, '\n')
  ---@type vim.Diagnostic[]
  local diagnostics = {}
  for i, line in ipairs(lines) do
    local message = ''
    local file, lnum, col = line:match("thread '[^']+' panicked at ([^:]+):(%d+):(%d+):")
    if lnum and col and message and vim.endswith(file_name, file) then
      local next_i = i + 1
      while #lines >= next_i and lines[next_i] ~= '' do
        message = message .. lines[next_i] .. '\n'
        next_i = next_i + 1
      end
      local diagnostic = {
        lnum = tonumber(lnum) - 1,
        col = tonumber(col) or 0,
        message = message,
        source = 'rustaceanvim',
        severity = vim.diagnostic.severity.ERROR,
      }
      table.insert(diagnostics, diagnostic)
    end
  end
  if #diagnostics == 0 then
    --- Fall back to old format
    for message, file, lnum, col in output:gmatch("thread '[^']+' panicked at '([^']+)', ([^:]+):(%d+):(%d+)") do
      if vim.endswith(file_name, file) then
        local diagnostic = {
          lnum = tonumber(lnum) - 1,
          col = tonumber(col) or 0,
          message = message,
          source = 'rustaceanvim',
          severity = vim.diagnostic.severity.ERROR,
        }
        table.insert(diagnostics, diagnostic)
      end
    end
  end
  return diagnostics
end

M.execute_command = function(command, args, cwd, opts)
  ---@type RustaceanExecutorOpts
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
  local compat = require('rustaceanvim.compat')
  local cmd = vim.list_extend({ command }, args)
  local fname = vim.api.nvim_buf_get_name(opts.bufnr)
  compat.system(cmd, { cwd = cwd }, function(sc)
    ---@cast sc vim.SystemCompleted
    if sc.code == 0 then
      local summary = get_test_summary(sc.stdout or '')
      vim.schedule(function()
        vim.notify(summary and summary or (notify_prefix .. 'passed!'), vim.log.levels.INFO)
      end)
      return
    end
    local output = (sc.stderr or '') .. '\n' .. (sc.stdout or '')
    local diagnostics = M.parse_diagnostics(fname, output)
    local summary = get_test_summary(sc.stdout or '')
    vim.schedule(function()
      vim.diagnostic.set(diag_namespace, opts.bufnr, diagnostics)
      vim.cmd.redraw()
      vim.notify(summary and summary or (notify_prefix .. 'failed!'), vim.log.levels.ERROR)
    end)
  end)
end

return M
