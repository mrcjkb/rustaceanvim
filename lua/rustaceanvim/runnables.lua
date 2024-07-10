local config = require('rustaceanvim.config.internal')
local overrides = require('rustaceanvim.overrides')

local M = {}

---@return { textDocument: lsp_text_document, position: nil }
local function get_params()
  return {
    textDocument = vim.lsp.util.make_text_document_params(0),
    position = nil, -- get em all
  }
end

---@class RARunnable
---@field args RARunnableArgs
---@field label string
---@field location? RARunnableLocation

---@class RARunnableLocation
---@field targetRange lsp.Range
---@field targetSelectionRange lsp.Range

---@class RARunnableArgs
---@field workspaceRoot string
---@field cargoArgs string[]
---@field cargoExtraArgs? string[]
---@field executableArgs string[]

---@param option string
---@return string
local function prettify_test_option(option)
  for _, prefix in pairs { 'test-mod ', 'test ', 'cargo test -p ' } do
    if vim.startswith(option, prefix) then
      return option:sub(prefix:len() + 1, option:len()):gsub('%-%-all%-targets', '(all targets)') or option
    end
  end
  return option:gsub('%-%-all%-targets', '(all targets)') or option
end

---@param result RARunnable[]
---@param executableArgsOverride? string[]
---@param opts RunnablesOpts
---@return string[]
local function get_options(result, executableArgsOverride, opts)
  local option_strings = {}

  for _, runnable in ipairs(result) do
    local str = runnable.label
      .. (
        executableArgsOverride and #executableArgsOverride > 0 and ' -- ' .. table.concat(executableArgsOverride, ' ')
        or ''
      )
    if opts.tests_only then
      str = prettify_test_option(str)
    end
    if config.tools.cargo_override then
      str = str:gsub('^cargo', config.tools.cargo_override)
    end
    table.insert(option_strings, str)
  end

  return option_strings
end

---@alias CargoCmd 'cargo'

---@param runnable RARunnable
---@return string executable
---@return string[] args
---@return string | nil dir
function M.get_command(runnable)
  local args = runnable.args

  local dir = args.workspaceRoot

  local ret = vim.list_extend({}, args.cargoArgs or {})
  ret = vim.list_extend(ret, args.cargoExtraArgs or {})
  table.insert(ret, '--')
  ret = vim.list_extend(ret, args.executableArgs or {})
  if
    config.tools.enable_nextest
    and not config.tools.cargo_override
    and not vim.startswith(runnable.label, 'doctest')
  then
    ret = overrides.try_nextest_transform(ret)
  end

  return config.tools.cargo_override or 'cargo', ret, dir
end

---@param choice integer
---@param runnables RARunnable[]
---@return CargoCmd command build command
---@return string[] args
---@return string|nil dir
local function getCommand(choice, runnables)
  return M.get_command(runnables[choice])
end

---@param choice integer
---@param runnables RARunnable[]
function M.run_command(choice, runnables)
  -- do nothing if choice is too high or too low
  if not choice or choice < 1 or choice > #runnables then
    return
  end

  local opts = config.tools

  local command, args, cwd = getCommand(choice, runnables)
  if not cwd then
    return
  end

  if #args > 0 and (vim.startswith(args[1], 'test') or vim.startswith(args[1], 'nextest')) then
    local test_executor = vim.tbl_contains(args, '--all-targets') and opts.crate_test_executor or opts.test_executor
    test_executor.execute_command(command, args, cwd, {
      bufnr = vim.api.nvim_get_current_buf(),
      runnable = runnables[choice],
    })
  else
    opts.executor.execute_command(command, args, cwd)
  end
end

---@param runnable RARunnable
---@return boolean
local function is_testable(runnable)
  ---@cast runnable RARunnable
  local cargoArgs = runnable.args and runnable.args.cargoArgs or {}
  return #cargoArgs > 0 and vim.startswith(cargoArgs[1], 'test')
end

---@param executableArgsOverride? string[]
---@param runnables RARunnable[]
---@return RARunnable[]
function M.apply_exec_args_override(executableArgsOverride, runnables)
  if type(executableArgsOverride) == 'table' and #executableArgsOverride > 0 then
    local unique_runnables = {}
    for _, runnable in pairs(runnables) do
      runnable.args.executableArgs = executableArgsOverride
      unique_runnables[vim.inspect(runnable)] = runnable
    end
    runnables = vim.tbl_values(unique_runnables)
  end
  return runnables
end

---@param executableArgsOverride? string[]
---@param opts RunnablesOpts
---@return fun(_, result: RARunnable[])
local function mk_handler(executableArgsOverride, opts)
  ---@param runnables RARunnable[]
  return function(_, runnables)
    if runnables == nil then
      return
    end
    runnables = M.apply_exec_args_override(executableArgsOverride, runnables)
    if opts.tests_only then
      runnables = vim.tbl_filter(is_testable, runnables)
    end

    -- get the choice from the user
    local options = get_options(runnables, executableArgsOverride, opts)
    vim.ui.select(options, { prompt = 'Runnables', kind = 'rust-tools/runnables' }, function(_, choice)
      ---@cast choice integer
      M.run_command(choice, runnables)

      local cached_commands = require('rustaceanvim.cached_commands')
      if opts.tests_only then
        cached_commands.set_last_testable(choice, runnables)
      else
        cached_commands.set_last_runnable(choice, runnables)
      end
    end)
  end
end

---@param position lsp.Position
---@param targetRange lsp.Range
local function is_within_range(position, targetRange)
  return targetRange.start.line <= position.line and targetRange['end'].line >= position.line
end

---@param runnables RARunnable
---@return integer | nil choice
function M.get_runnable_at_cursor_position(runnables)
  ---@type lsp.Position
  local position = vim.lsp.util.make_position_params().position
  ---@type integer|nil, integer|nil
  local choice, fallback
  for idx, runnable in ipairs(runnables) do
    if runnable.location then
      local range = runnable.location.targetRange
      if is_within_range(position, range) then
        if vim.startswith(runnable.label, 'test-mod') then
          fallback = idx
        else
          choice = idx
          break
        end
      end
    end
  end
  return choice or fallback
end

local function mk_cursor_position_handler(executableArgsOverride)
  ---@param runnables RARunnable[]
  return function(_, runnables)
    if runnables == nil then
      return
    end
    runnables = M.apply_exec_args_override(executableArgsOverride, runnables)
    local choice = M.get_runnable_at_cursor_position(runnables)
    if not choice then
      vim.notify('No runnable targets found for the current position.', vim.log.levels.ERROR)
      return
    end
    M.run_command(choice, runnables)
    local cached_commands = require('rustaceanvim.cached_commands')
    if is_testable(runnables[choice]) then
      cached_commands.set_last_testable(choice, runnables)
    end
    cached_commands.set_last_runnable(choice, runnables)
  end
end

---@class RunnablesOpts
---@field tests_only? boolean

---Sends the request to rust-analyzer to get the runnables and handles them
---@param executableArgsOverride? string[]
---@param opts? RunnablesOpts
function M.runnables(executableArgsOverride, opts)
  ---@type RunnablesOpts
  opts = vim.tbl_deep_extend('force', { tests_only = false }, opts or {})
  vim.lsp.buf_request(0, 'experimental/runnables', get_params(), mk_handler(executableArgsOverride, opts))
end

function M.run(executableArgsOverride)
  vim.lsp.buf_request(0, 'experimental/runnables', get_params(), mk_cursor_position_handler(executableArgsOverride))
end

return M
