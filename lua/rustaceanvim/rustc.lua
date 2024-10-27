local M = {}

--- Default target value for rustc when no specific target is provided.
--- Used as a fallback to let rustc determine the appropriate target based on the OS.
M.DEFAULT_RUSTC_TARGET = 'OS'

---Local rustc targets cache
local rustc_targets_cache = nil

---Handles retrieving rustc target architectures and running the passed in callback
---to perform certain actions using the retrieved targets.
---@param callback fun(targets: string[])
M.with_rustc_target_architectures = function(callback)
  if rustc_targets_cache then
    return callback(rustc_targets_cache)
  end
  vim.system(
    { 'rustc', '--print', 'target-list' },
    { text = true },
    ---@param result vim.SystemCompleted
    function(result)
      if result.code ~= 0 then
        error('Failed to retrieve rustc targets: ' .. result.stderr)
      end
      rustc_targets_cache = vim.iter(result.stdout:gmatch('[^\r\n]+')):fold(
        {},
        ---@param acc table<string, boolean>
        ---@param target string
        function(acc, target)
          acc[target] = true
          return acc
        end
      )
      return callback(rustc_targets_cache)
    end
  )
end

return M
