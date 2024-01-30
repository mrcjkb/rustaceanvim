local M = {}

---@param file_name string
---@param output string
---@return rustaceanvim.Diagnostic[]
---@diagnostic disable-next-line: inject-field
M.parse_diagnostics = function(file_name, output)
  output = output:gsub('\r\n', '\n')
  local lines = vim.split(output, '\n')
  ---@type rustaceanvim.Diagnostic[]
  local diagnostics = {}
  for i, line in ipairs(lines) do
    local message = ''
    local test_id, file, lnum, col = line:match("thread '([^']+)' panicked at ([^:]+):(%d+):(%d+):")
    if lnum and col and message and vim.endswith(file_name, file) then
      local next_i = i + 1
      while #lines >= next_i and lines[next_i] ~= '' do
        message = message .. lines[next_i] .. '\n'
        next_i = next_i + 1
      end
      ---@type rustaceanvim.Diagnostic
      local diagnostic = {
        test_id = test_id,
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
    for test_id, message, file, lnum, col in
      output:gmatch("thread '([^']+)' panicked at '([^']+)', ([^:]+):(%d+):(%d+)")
    do
      if vim.endswith(file_name, file) then
        ---@type rustaceanvim.Diagnostic
        local diagnostic = {
          test_id = test_id,
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

return M
