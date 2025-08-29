local M = {}

-- Function to escape HTML special characters in a string
---@param input string The string to escape
---@return string input The escaped string
---@return integer count
local function unescape_html(input)
  return input:gsub('&amp;', '&'):gsub('&lt;', '<'):gsub('&gt;', '>'):gsub('&quot;', '"'):gsub('&apos;', "'")
end

---@param input string The string to remove ansi codes from
---@return string input
local function remove_ansi_codes(input)
  local result = input
    :gsub('\27%[%d+;%d+;%d+;%d+;%d+m', '')
    :gsub('\27%[%d+;%d+;%d+;%d+m', '')
    :gsub('\27%[%d+;%d+;%d+m', '')
    :gsub('\27%[%d+;%d+m', '')
    :gsub('\27%[%d+m', '')
  return result
end

---@param output string
---@param bufnr integer
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
function M.parse_cargo_test_diagnostics(output, bufnr)
  output = output:gsub('\r\n', '\n')
  local diagnostics = {}

  for failure_content, test_id, lnum, col in
    output:gmatch("(thread '([^']+)' panicked at [^:]+:(%d+):(%d+):%s-\n.-\n)\n")
  do
    table.insert(diagnostics, {
      bufnr = bufnr,
      test_id = test_id,
      lnum = tonumber(lnum),
      end_lnum = tonumber(lnum),
      col = tonumber(col),
      end_col = tonumber(col),
      message = remove_ansi_codes(unescape_html(failure_content)),
      source = 'rustaceanvim',
      severity = vim.diagnostic.severity.ERROR,
    })
  end

  if #diagnostics == 0 then
    --- Fall back to old format
    for test_id, message, _, lnum, col in output:gmatch("thread '([^']+)' panicked at '([^']+)', ([^:]+):(%d+):(%d+)") do
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
        message = remove_ansi_codes(unescape_html(message)),
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
      message = remove_ansi_codes(unescape_html(failure_content)),
      source = 'rustaceanvim',
      severity = vim.diagnostic.severity.ERROR,
    })
  end

  return diagnostics
end

return M
