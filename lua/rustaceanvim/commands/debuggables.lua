local M = {}

local compat = require('rustaceanvim.compat')
local ra_runnables = require('rustaceanvim.runnables')
local config = require('rustaceanvim.config.internal')

---@return { textDocument: lsp_text_document, position: nil }
local function get_params()
  return {
    textDocument = vim.lsp.util.make_text_document_params(),
    position = nil, -- get em all
  }
end

---@type { [string]: boolean? } Used to prevent this plugin from adding the same configuration twice
local _dap_configuration_added = {}

---@param args RARunnableArgs
---@return string
local function build_label(args)
  local ret = ''
  for _, value in ipairs(args.cargoArgs) do
    ret = ret .. value .. ' '
  end

  for _, value in ipairs(args.cargoExtraArgs or {}) do
    ret = ret .. value .. ' '
  end

  if not vim.tbl_isempty(args.executableArgs) then
    ret = ret .. '-- '
    for _, value in ipairs(args.executableArgs) do
      ret = ret .. value .. ' '
    end
  end
  return ret
end

---@param result RARunnable[]
---@return string[] option_strings
local function get_options(result)
  ---@type string[]
  local option_strings = {}

  for _, debuggable in ipairs(result) do
    local label = build_label(debuggable.args)
    local str = label
    if config.tools.cargo_override then
      str = str:gsub('^cargo', config.tools.cargo_override)
    end
    table.insert(option_strings, str)
  end

  return option_strings
end

---@param args RARunnableArgs
---@return boolean
local function is_valid_test(args)
  local is_not_cargo_check = args.cargoArgs[1] ~= 'check'
  return is_not_cargo_check
end

-- rust-analyzer doesn't actually support giving a list of debuggable targets,
-- so work around that by manually removing non debuggable targets (only cargo
-- check for now).
-- This function also makes it so that the debuggable commands are more
-- debugging friendly. For example, we move cargo run to cargo build, and cargo
-- test to cargo test --no-run.
---@param result RARunnable[]
local function sanitize_results_for_debugging(result)
  ---@type RARunnable[]
  local ret = vim.tbl_filter(function(value)
    ---@cast value RARunnable
    return is_valid_test(value.args)
  end, result or {})

  local overrides = require('rustaceanvim.overrides')
  for _, value in ipairs(ret) do
    overrides.sanitize_command_for_debugging(value.args.cargoArgs)
  end

  return ret
end

local function dap_run(args)
  local rt_dap = require('rustaceanvim.dap')
  local ok, dap = pcall(require, 'dap')
  if ok then
    rt_dap.start(args, true, dap.run)
    local cached_commands = require('rustaceanvim.cached_commands')
    cached_commands.set_last_debuggable(args)
  else
    vim.notify('nvim-dap is required for debugging', vim.log.levels.ERROR)
    return
  end
end

---@param debuggables RARunnable[]
---@param executableArgsOverride? string[]
local function ui_select_debuggable(debuggables, executableArgsOverride)
  debuggables = ra_runnables.apply_exec_args_override(executableArgsOverride, debuggables)
  local options = get_options(debuggables)
  if #options == 0 then
    return
  end
  vim.ui.select(options, { prompt = 'Debuggables', kind = 'rust-tools/debuggables' }, function(_, choice)
    if choice == nil then
      return
    end
    local args = debuggables[choice].args
    dap_run(args)
  end)
end

---@param debuggables RARunnable[]
local function add_debuggables_to_nvim_dap(debuggables)
  local ok, dap = pcall(require, 'dap')
  if not ok then
    return
  end
  local rt_dap = require('rustaceanvim.dap')
  dap.configurations.rust = dap.configurations.rust or {}
  for _, debuggable in pairs(debuggables) do
    rt_dap.start(debuggable.args, false, function(configuration)
      local name = 'Cargo: ' .. build_label(debuggable.args)
      if not _dap_configuration_added[name] then
        configuration.name = name
        table.insert(dap.configurations.rust, configuration)
        _dap_configuration_added[name] = true
      end
    end)
  end
end

---@param debuggables RARunnable[]
---@param executableArgsOverride? string[]
local function debug_at_cursor_position(debuggables, executableArgsOverride)
  if debuggables == nil then
    return
  end
  debuggables = ra_runnables.apply_exec_args_override(executableArgsOverride, debuggables)
  local choice = ra_runnables.get_runnable_at_cursor_position(debuggables)
  if not choice then
    vim.notify('No debuggable targets found for the current position.', vim.log.levels.ERROR)
    return
  end
  local args = debuggables[choice].args
  dap_run(args)
end

---@param callback fun(result:RARunnable[])
local function mk_handler(callback)
  return function(_, result, _, _)
    ---@cast result RARunnable[]
    if result == nil then
      return
    end
    result = sanitize_results_for_debugging(result)
    callback(result)
  end
end

local rl = require('rustaceanvim.rust_analyzer')

---@param handler? lsp.Handler See |lsp-handler|
local function runnables_request(handler)
  rl.buf_request(0, 'experimental/runnables', get_params(), handler)
end

---Sends the request to rust-analyzer to get the debuggables and handles them
---@param executableArgsOverride? string[]
function M.debuggables(executableArgsOverride)
  runnables_request(mk_handler(function(debuggables)
    ui_select_debuggable(debuggables, executableArgsOverride)
  end))
end

---Runs the debuggable under the cursor, if present
---@param executableArgsOverride? string[]
function M.debug(executableArgsOverride)
  runnables_request(mk_handler(function(debuggables)
    debug_at_cursor_position(debuggables, executableArgsOverride)
  end))
end

--- Sends the request to rust-analyzer to get the debuggables and adds them to nvim-dap's
--- configurations
function M.add_dap_debuggables()
  -- Defer, because rust-analyzer may not be ready yet
  runnables_request(mk_handler(add_debuggables_to_nvim_dap))
  local timer = compat.uv.new_timer()
  timer:start(
    2000,
    0,
    vim.schedule_wrap(function()
      runnables_request(mk_handler(add_debuggables_to_nvim_dap))
    end)
  )
end

return M
