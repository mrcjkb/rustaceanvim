local M = {}

---@param fname string
---@param output string
---@param bufnr integer
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
function M.parse_cargo_test_diagnostics(fname, output, bufnr)
  output = output:gsub('\r\n', '\n')
  local lines = vim.split(output, '\n')
  ---@type rustaceanvim.Diagnostic[]
  local diagnostics = {}
  for i, line in ipairs(lines) do
    local message = ''
    local test_id, file, lnum, col = line:match("thread '([^']+)' panicked at ([^:]+):(%d+):(%d+):")
    if lnum and col and message and vim.endswith(fname, file) then
      local next_i = i + 1
      while #lines >= next_i and lines[next_i] ~= '' do
        message = message .. lines[next_i] .. '\n'
        next_i = next_i + 1
      end
      local diagnostic_lnum = tonumber(lnum) - 1
      local diagnostic_col = tonumber(col) or 0
      ---@type rustaceanvim.Diagnostic
      local diagnostic = {
        bufnr = bufnr,
        test_id = test_id,
        lnum = diagnostic_lnum,
        end_lnum = diagnostic_lnum,
        col = diagnostic_col,
        end_col = diagnostic_col,
        message = message,
        source = 'rustaceanvim',
        severity = vim.diagnostic.severity.ERROR,
      }
      table.insert(diagnostics, diagnostic)
    end
  end
  if #diagnostics == 0 then
    --- Fall back to old format
    for test_id, message, file, lnum, col in
      output:gmatch("thread '([^']+)' panicked at '([^']+)', ([^:]+):(%d+):(%d+)")
    do
      if vim.endswith(fname, file) then
        local diagnostic_lnum = tonumber(lnum) - 1
        local diagnostic_col = tonumber(col) or 0
        ---@type rustaceanvim.Diagnostic
        local diagnostic = {
          bufnr = bufnr,
          test_id = test_id,
          lnum = diagnostic_lnum,
          end_lnum = diagnostic_lnum,
          col = diagnostic_col,
          end_col = diagnostic_col,
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

---@param junit_xml string
---@param bufnr integer
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
function M.parse_nextest_diagnostics(junit_xml, bufnr)
  local diagnostics = {}
  for test_id, _, lnum, col, failure_content in
    junit_xml:gmatch(
      '<failure.-message="thread &apos;([^;]+)&apos; panicked at ([^:]+):(%d+):(%d+)".-<system%-err>(.-)</system%-err>'
    )
  do
    table.insert(diagnostics, {
      bufnr = bufnr,
      test_id = test_id,
      lnum = lnum,
      end_lnum = lnum,
      col = col,
      end_col = col,
      message = failure_content,
      source = 'rustaceanvim',
      severity = vim.diagnostic.severity.ERROR,
    })
  end

  return diagnostics
end

return M
