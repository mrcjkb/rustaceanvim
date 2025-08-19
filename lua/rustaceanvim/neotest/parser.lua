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
  -- NOTE: ignore ANSI character for ok, if present: ^[[32mok^[[0;10m
  for test_name in output_content:gmatch('\ntest%s+([^\n]-)%s+%.%.%.%s+\27?%[?[0-9;]-m?ok\27?%[?[0-9;]-m?\r?\n') do
    results[trans.get_position_id(context.file, test_name)] = {
      status = 'passed',
    }
  end
  return results
end

return M
