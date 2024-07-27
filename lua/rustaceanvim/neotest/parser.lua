local M = {}

local trans = require('rustaceanvim.neotest.trans')

---NOTE: This mutates results
---
---@param results table<string, neotest.Result>
---@param context rustaceanvim.neotest.RunContext
---@param output_content string
---@return table<string, neotest.Result> results
function M.populate_pass_positions(results, context, output_content)
  -- XXX: match doesn't work here because it needs to
  -- match on the end of each line
  -- TODO: Use cargo-nextest's JUnit output in the future?
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
