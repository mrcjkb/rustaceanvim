local M = {}

---@param output string
---@param bufnr integer
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
function M.parse_cargo_test_diagnostics(output, bufnr)
  output = output:gsub('\r\n', '\n')
  local diagnostics = {}

  for failure_content, test_id, lnum, col in
    output:gmatch("(thread '([^']+)' panicked at [^:]+:(%d+):(%d+):%s-\n.-\n)note: ")
  do
    table.insert(diagnostics, {
      bufnr = bufnr,
      test_id = test_id,
      lnum = tonumber(lnum),
      end_lnum = tonumber(lnum),
      col = tonumber(col),
      end_col = tonumber(col),
      message = failure_content,
      source = 'rustaceanvim',
      severity = vim.diagnostic.severity.ERROR,
    })
  end

  if #diagnostics == 0 then
    --- Fall back to old format
    for test_id, message, file, lnum, col in
      output:gmatch("thread '([^']+)' panicked at '([^']+)', ([^:]+):(%d+):(%d+)")
    do
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
      lnum = tonumber(lnum),
      end_lnum = tonumber(lnum),
      col = tonumber(col),
      end_col = tonumber(col),
      message = failure_content,
      source = 'rustaceanvim',
      severity = vim.diagnostic.severity.ERROR,
    })
  end

  return diagnostics
end

return M
