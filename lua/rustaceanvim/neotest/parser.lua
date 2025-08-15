local M = {}

local trans = require('rustaceanvim.neotest.trans')

---NOTE: This mutates results
---
---@param results table<string, neotest.Result>
---@param context rustaceanvim.neotest.RunContext
---@param junit_xml string
---@return table<string, neotest.Result> results
function M.populate_pass_positions_nextest(results, context, junit_xml)
  for test_name, contents in junit_xml:gmatch('<testcase.-name="([^"]+)".->(.-)</testcase>') do
    if not contents:match('</failure>') then
      results[trans.get_position_id(context.file, test_name)] = {
        status = 'passed',
      }
    end
  end

  return results
end

---NOTE: This mutates results
---
---@param results table<string, neotest.Result>
---@param context rustaceanvim.neotest.RunContext
---@param output_content string
---@return table<string, neotest.Result> results
function M.populate_pass_positions_cargo_test(results, context, output_content)
  local lines = vim.split(output_content, '\n') or {}
  vim
    .iter(lines)
    ---@param line string
    :map(function(line)
      return line:match('PASS%s.*%s(%S+)$') or line:match('test%s(%S+)%s...%sok')
    end)
    ---@param result string | nil
    :filter(function(result)
      return result ~= nil
    end)
    ---@param pos string
    :map(function(pos)
      return trans.get_position_id(context.file, pos)
    end)
    ---@param pos string
    :each(function(pos)
      results[pos] = {
        status = 'passed',
      }
    end)
  return results
end

return M
