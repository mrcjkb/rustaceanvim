local M = {}

---@param runnable rustaceanvim.RARunnable
---@return string | nil
local function get_test_path(runnable)
  local executableArgs = runnable.args and runnable.args.executableArgs or {}
  return #executableArgs > 0 and executableArgs[1] or nil
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
  local cargoArgs = runnable.args and runnable.args.cargoArgs or {}
  if #cargoArgs > 0 and vim.startswith(cargoArgs[1], 'test') then
    ---@type neotest.PositionType
    local type
    if vim.startswith(runnable.label, 'cargo test -p') then
      type = 'dir'
    elseif vim.startswith(runnable.label, 'test-mod') then
      type = 'namespace'
    elseif vim.startswith(runnable.label, 'test') or vim.startswith(runnable.label, 'doctest') then
      type = 'test'
    else
      return
    end
    local location = runnable.location
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
      name = test_path or runnable.label,
      type = type,
      path = file_path,
      range = { start_row, start_col, end_row, end_col },
      runnable = runnable,
    }
    return pos
  end
end

return M
