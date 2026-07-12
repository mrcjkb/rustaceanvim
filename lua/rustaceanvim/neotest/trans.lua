local M = {}

---@param runnable rustaceanvim.RARunnable
---@return string | nil
local function get_test_path(runnable)
  local runnables = require('rustaceanvim.runnables')
  local shellRunnable = runnables.as_shell_runnable(runnable)
  if shellRunnable then
    local shellArgs = shellRunnable.args and shellRunnable.args.args or {}
    return #shellArgs > 0 and shellArgs[#shellArgs] or nil
  end
  local cargoRunnable = runnables.as_cargo_runnable(runnable)
  if cargoRunnable then
    local executableArgs = cargoRunnable.args and cargoRunnable.args.executableArgs or {}
    return #executableArgs > 0 and executableArgs[1] or nil
  end
end

---@overload fun(file_path: string, test_path: string | nil)
---@overload fun(file_path: string, runnable: rustaceanvim.RARunnable)
---@return string
function M.get_position_id(file_path, runnable)
  local test_path = runnable
  if type(runnable) == 'table' then
    test_path = get_test_path(runnable)
  end
  ---@cast test_path string | nil
  return test_path and table.concat(vim.list_extend({ file_path }, { test_path }), '::') or file_path
end

---@param file_path string
---@param runnable rustaceanvim.RARunnable
---@return rustaceanvim.neotest.Position | nil
function M.runnable_to_position(file_path, runnable)
  local runnables = require('rustaceanvim.runnables')
  local cargoRunnable = runnables.as_cargo_runnable(runnable)
  if not cargoRunnable then
    return nil
  end
  local cargoArgs = cargoRunnable.args and cargoRunnable.args.cargoArgs or {}
  if #cargoArgs > 0 and vim.startswith(cargoArgs[1], 'test') then
    ---@type neotest.PositionType
    local type
    if vim.startswith(cargoRunnable.label, 'cargo test -p') then
      type = 'dir'
    elseif vim.startswith(cargoRunnable.label, 'test-mod') then
      type = 'namespace'
    elseif vim.startswith(cargoRunnable.label, 'test') or vim.startswith(cargoRunnable.label, 'doctest') then
      type = 'test'
    else
      return
    end
    local location = cargoRunnable.location
    local start_row, start_col, end_row, end_col = 0, 0, 0, 0
    if location then
      start_row = location.targetRange.start.line + 1
      start_col = location.targetRange.start.character
      end_row = location.targetRange['end'].line + 1
      end_col = location.targetRange['end'].character
    end
    local test_path = get_test_path(runnable)
    -- strip the file module prefix from the name
    if test_path then
      local mod_name = vim.fn.fnamemodify(file_path, ':t:r')
      if vim.startswith(test_path, mod_name .. '::') then
        test_path = test_path:sub(#mod_name + 3, #test_path)
      end
    end
    ---@type rustaceanvim.neotest.Position
    local pos = {
      id = M.get_position_id(file_path, runnable),
      name = test_path or cargoRunnable.label,
      type = type,
      path = file_path,
      range = { start_row, start_col, end_row, end_col },
      runnable = runnable,
    }
    return pos
  end
end

return M
