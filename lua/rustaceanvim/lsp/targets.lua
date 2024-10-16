local T = {}

local rustc_targets_cache = nil

--- Get rustc targets, use cache if available
---@return table<string, boolean>
local function get_rustc_targets()
  if rustc_targets_cache then
    return rustc_targets_cache
  end

  local result = vim.system({ 'rustc', '--print', 'target-list' }):wait()
  if result.code ~= 0 then
    error('Failed to retrieve rustc targets: ' .. result.stderr)
  end

  rustc_targets_cache = {}
  for line in result.stdout:gmatch('[^\r\n]+') do
    rustc_targets_cache[line] = true
  end

  return rustc_targets_cache
end

--- Validates if the provided target is a valid Rust compiler (rustc) target.
--- If no target is provided, it defaults to the system's architecture.
---@param target? string
---@return boolean
function T.target_is_valid_rustc_target(target)
  if target == nil then
    return true
  end

  local success, targets = pcall(get_rustc_targets)
  if not success then
    vim.notify('Error retrieving rustc targets: ' .. tostring(targets), vim.log.levels.ERROR)
    return false
  end

  return targets[target] or false
end

return T
