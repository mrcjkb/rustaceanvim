local M = {}

---@param output string
---@param bufnr integer
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
function M.parse_cargo_test_diagnostics(output, bufnr)
  output = output:gsub('\r\n', '\n')
  local diagnostics = {}

  for failure_content, test_id, lnum, col in
    output:gmatch("(thread '([^']+)' panicked at [^:]+:(%d+):(%d+):%s-\n.-\n\n)")
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
