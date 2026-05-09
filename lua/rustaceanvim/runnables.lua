local config = require('rustaceanvim.config.internal')
local overrides = require('rustaceanvim.overrides')
local ra = require('rustaceanvim.rust_analyzer')

local M = {}

---@return { textDocument: lsp_text_document, position: nil }
local function get_params()
  return {
    textDocument = vim.lsp.util.make_text_document_params(0),
    position = nil, -- get em all
  }
end

---This mirrors the [typescript definitions in rust-analyzer][ra]
---
---[ra]: https://github.com/rust-lang/rust-analyzer/blob/0dc46bfea9b17fed93ab57393971fb932e7a5dd4/editors/code/src/lsp_ext.ts#L232-L283
---
---Beware, Lua tooling does not do type narrowing well, and blindly merges all
---fields in the types for `.args`. You must provide runtime checks of
---runnable.kind. There are convenience functions `as_cargo_runnable` and
---`as_shell_runnable` that perform these checks and casts for you.
---
---@class rustaceanvim.RARunnable
---@field label string
---@field location? rustaceanvim.RARunnableLocation
---RA has had both cargo and shell runnables since 2024 (rust ~1.80). But it only
---started providing `kind: "cargo" | "shell"` in 2026. Before then it used
---serde(untagged) on the args enum. So it is safer not to rely on this field for
---now and presume it might be missing. Prefer checking presence of cargoArgs.
---@field kind? "cargo" | "shell"
---@field args {}

---@class rustaceanvim.RACargoRunnable
---@field kind? '"cargo"'
---@field label string
---@field location? rustaceanvim.RARunnableLocation
---@field args rustaceanvim.RACargoRunnableArgs

---@class rustaceanvim.RAShellRunnable
---@field kind? '"shell"'
---@field label string
---@field location? rustaceanvim.RARunnableLocation
---@field args rustaceanvim.RAShellRunnableArgs

---@class rustaceanvim.RARunnableLocation
---@field targetRange lsp.Range
---@field targetSelectionRange lsp.Range

---@class rustaceanvim.RACargoRunnableArgs
---@field cwd string
---@field environment? table<string, string>
---@field workspaceRoot string
---@field cargoArgs string[]
---@field cargoExtraArgs? string[]
---@field executableArgs string[]
---@field overrideCargo? string

---@class rustaceanvim.RAShellRunnableArgs
---@field cwd string
---@field environment? table<string, string>
---@field program string
---@field args string[]

---A union (read: merged fields) of the two runnable args types.
---@alias rustaceanvim.RARunnableArgs rustaceanvim.RACargoRunnableArgs | rustaceanvim.RAShellRunnableArgs

---@param runnable rustaceanvim.RARunnable
---@return rustaceanvim.RACargoRunnable | nil
function M.as_cargo_runnable(runnable)
  ---@type rustaceanvim.RARunnableArgs
  local args = runnable.args
  if args and args.cargoArgs then
    return runnable --[[@as rustaceanvim.RACargoRunnable]]
  end
end

---@param runnable_args rustaceanvim.RARunnableArgs
---@return rustaceanvim.RACargoRunnableArgs | nil
function M.as_cargo_runnable_args(runnable_args)
  if runnable_args and runnable_args.cargoArgs then
    return runnable_args --[[@as rustaceanvim.RACargoRunnableArgs]]
  end
end

---@param runnable rustaceanvim.RARunnable
---@return rustaceanvim.RAShellRunnable | nil
function M.as_shell_runnable(runnable)
  ---@type rustaceanvim.RARunnableArgs
  local args = runnable.args
  if args and not args.cargoArgs then
    return runnable --[[@as rustaceanvim.RAShellRunnable]]
  end
end

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

---@param result rustaceanvim.RARunnable[]
---@param executableArgsOverride? string[]
---@param opts rustaceanvim.runnables.Opts
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

---@alias rustaceanvim.CargoCmd 'cargo'

---@param runnable rustaceanvim.RARunnable
---@return string executable
---@return string[] args
---@return string | nil dir
---@return table<string, string> | nil env
function M.get_command(runnable)
  local shellRunnable = M.as_shell_runnable(runnable)
  if shellRunnable then
    local args = shellRunnable.args
    return args.program, args.args or {}, args.cwd, args.environment
  end
  local cargoRunnable = M.as_cargo_runnable(runnable)
  if not cargoRunnable then
    error(
      'Unsupported runnable type: '
        .. (runnable.kind or '<unspecified>')
        .. '. Only cargo and shell runnables are supported.'
    )
  end

  local args = cargoRunnable.args
  local dir = args.workspaceRoot
  local env = args.environment

  local ret = vim.list_extend({}, args.cargoArgs or {})
  ret = vim.list_extend(ret, args.cargoExtraArgs or {})
  table.insert(ret, '--')
  ret = vim.list_extend(ret, args.executableArgs or {})
  if
    config.tools.enable_nextest
    and not config.tools.cargo_override
    and not vim.startswith(runnable.label, 'doctest')
  then
    ret = overrides.maybe_nextest_transform(ret)
  end

  return config.tools.cargo_override or 'cargo', ret, dir, env
end

---@param choice integer
---@param runnables rustaceanvim.RARunnable[]
---@return rustaceanvim.CargoCmd command build command
---@return string[] args
---@return string|nil dir
---@return table<string, string> | nil env
local function getCommand(choice, runnables)
  return M.get_command(runnables[choice])
end

---@param choice integer
---@param runnables rustaceanvim.RARunnable[]
function M.run_command(choice, runnables)
  -- do nothing if choice is too high or too low
  if not choice or choice < 1 or choice > #runnables then
    return
  end

  local opts = config.tools

  local command, args, cwd, env = getCommand(choice, runnables)
  if not cwd then
    return
  end

  if #args > 0 and (vim.startswith(args[1], 'test') or vim.startswith(args[1], 'nextest')) then
    local test_executor = vim.tbl_contains(args, '--all-targets') and opts.crate_test_executor or opts.test_executor
    test_executor.execute_command(command, args, cwd, {
      bufnr = vim.api.nvim_get_current_buf(),
      env = env,
      runnable = runnables[choice],
    })
  else
    opts.executor.execute_command(command, args, cwd, { env = env })
  end
end

---@param runnable rustaceanvim.RARunnable
---@return boolean
local function is_testable(runnable)
  ---@cast runnable rustaceanvim.RARunnable
  local cargoRunnable = M.as_cargo_runnable(runnable)
  if not cargoRunnable then
    return false
  end
  local cargoArgs = cargoRunnable.args.cargoArgs
  return #cargoArgs > 0 and vim.startswith(cargoArgs[1], 'test')
end

---@param executableArgsOverride? string[]
---@param runnables rustaceanvim.RARunnable[]
---@return rustaceanvim.RARunnable[]
function M.apply_exec_args_override(executableArgsOverride, runnables)
  if type(executableArgsOverride) == 'table' and #executableArgsOverride > 0 then
    local unique_runnables = {}
    for _, runnable in pairs(runnables) do
      local cargoRunnable = M.as_cargo_runnable(runnable)
      if not cargoRunnable then
        unique_runnables[vim.inspect(runnable)] = runnable
      else
        local args = cargoRunnable.args.executableArgs
        local override_args = {}
        if #args > 0 and not vim.startswith(args[1], '--') then
          -- This is a target arg. We want to keep it.
          override_args = { args[1] }
          if #args > 1 and args[2] == '--exact' then
            -- We're matching the target exactly. We should keep this.
            table.insert(override_args, args[2])
          end
        end
        cargoRunnable.args.executableArgs = vim.list_extend(override_args, executableArgsOverride)
        unique_runnables[vim.inspect(cargoRunnable)] = cargoRunnable
      end
    end
    runnables = vim.tbl_values(unique_runnables)
  end
  return runnables
end

---@param executableArgsOverride? string[]
---@param opts rustaceanvim.runnables.Opts
---@return fun(_, result: rustaceanvim.RARunnable[])
local function mk_handler(executableArgsOverride, opts)
  ---@param runnables rustaceanvim.RARunnable[]
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

---@param runnables rustaceanvim.RARunnable
---@return integer | nil choice
function M.get_runnable_at_cursor_position(runnables)
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  ---@type lsp.Position
  local position = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8').position
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
  ---@param runnables rustaceanvim.RARunnable[]
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

---@class rustaceanvim.runnables.Opts
---@field tests_only? boolean

---Sends the request to rust-analyzer to get the runnables and handles them
---@param executableArgsOverride? string[]
---@param opts? rustaceanvim.runnables.Opts
function M.runnables(executableArgsOverride, opts)
  ---@type rustaceanvim.runnables.Opts
  opts = vim.tbl_deep_extend('force', { tests_only = false }, opts or {})
  ra.buf_request(0, 'experimental/runnables', get_params(), mk_handler(executableArgsOverride, opts))
end

function M.run(executableArgsOverride)
  ra.buf_request(0, 'experimental/runnables', get_params(), mk_cursor_position_handler(executableArgsOverride))
end

return M
