---@mod rustaceanvim.config.check rustaceanvim configuration check

local types = require('rustaceanvim.types.internal')

local M = {}

---@param name string Argument name
---@param value unknown Argument value
---@param validator vim.validate.Validator
---   - (`string|string[]`): Any value that can be returned from |lua-type()| in addition to
---     `'callable'`: `'boolean'`, `'callable'`, `'function'`, `'nil'`, `'number'`, `'string'`, `'table'`,
---     `'thread'`, `'userdata'`.
---   - (`fun(val:any): boolean, string?`) A function that returns a boolean and an optional
---     string message.
---@param optional? boolean Argument is optional (may be omitted)
---@param message? string message when validation fails
---@see vim.validate
---@return boolean is_valid
---@return string|nil error_message
local function validate(name, value, validator, optional, message)
  local ok, err = pcall(vim.validate, name, value, validator, optional, message)
  return ok or false, 'Rocks: Invalid config' .. (err and ': ' .. err or '')
end

---Validates the config.
---@param cfg rustaceanvim.Config
---@return boolean is_valid
---@return string|nil error_message
function M.validate(cfg)
  local ok, err
  local tools = cfg.tools
  ok, err = validate('rustaceanvim.tools', tools, 'table')
  if not ok then
    return false, err
  end

  local crate_graph = tools.crate_graph
  ok, err = validate('rustaceanvim.tools.crate_graph', crate_graph, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.backend', crate_graph.backend, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate(
    'rustaceanvim.tools.crate_graph.enabled_graphviz_backends',
    crate_graph.enabled_graphviz_backends,
    'table',
    true
  )
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.full', crate_graph.full, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.output', crate_graph.output, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_graph.pipe', crate_graph.pipe, 'string', true)
  if not ok then
    return false, err
  end

  local code_actions = tools.code_actions
  ok, err = validate('rustaceanvim.tools.code_actions', code_actions, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.group_icon', code_actions.group_icon, 'string')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.ui_select_fallback', code_actions.ui_select_fallback, 'boolean')
  if not ok then
    return false, err
  end
  local keys = code_actions.keys
  ok, err = validate('rustaceanvim.tools.code_actions.keys', keys, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.keys.confirm', keys.confirm, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.code_actions.keys.quit', keys.quit, { 'table', 'string' })
  if not ok then
    return false, err
  end
  local float_win_config = tools.float_win_config
  ok, err = validate('rustaceanvim.tools.float_win_config', float_win_config, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.float_win_config.auto_focus', float_win_config.auto_focus, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.float_win_config.open_split', float_win_config.open_split, 'string')
  if not ok then
    return false, err
  end
  local rustc = tools.rustc
  ok, err = validate('rustaceanvim.tools.rustc', rustc, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.rustc.default_edition', rustc.default_edition, 'string')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.executor', tools.executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.test_executor', tools.test_executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.crate_test_executor', tools.crate_test_executor, { 'table', 'string' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.cargo_override', tools.cargo_override, 'string', true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.enable_nextest', tools.enable_nextest, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.enable_clippy', tools.enable_clippy, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.on_initialized', tools.on_initialized, 'function', true)
  if not ok then
    return false, err
  end
  ok, err =
    validate('rustaceanvim.tools.reload_workspace_from_cargo_toml', tools.reload_workspace_from_cargo_toml, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.tools.open_url', tools.open_url, 'function', true)
  if not ok then
    return false, err
  end
  local server = cfg.server
  ok, err = validate('rustaceanvim.server', server, 'table')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.cmd', server.cmd, { 'function', 'table' })
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.standalone', server.standalone, 'boolean')
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.settings', server.settings, { 'function', 'table' }, true)
  if not ok then
    return false, err
  end
  ok, err = validate('rustaceanvim.server.root_dir', server.root_dir, { 'function', 'string' }, true)
  if not ok then
    return false, err
  end
  if type(server.settings) == 'table' then
    ok, err = validate('rustaceanvim.server.settings[rust-analyzer]', server.settings['rust-analyzer'], 'table', true)
    if not ok then
      return false, err
    end
  end

  local dap = cfg.dap
  ok, err = validate('rustaceanvim.dap', dap, 'table')
  if not ok then
    return false, err
  end

  local adapter = types.evaluate(dap.adapter)
  if adapter == false then
    ok = true
  elseif adapter.type == 'executable' then
    ---@cast adapter rustaceanvim.dap.executable.Config
    ok, err = validate('rustaceanvim.dap.adapter.command [executable]', adapter.command, 'string')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.name [executable]', adapter.name, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.args [executable]', adapter.args, 'table', true)
    if not ok then
      return false, err
    end
  elseif adapter.type == 'server' then
    ---@cast adapter rustaceanvim.dap.server.Config
    local executable = adapter.executable
    ok, err = validate('rustaceanvim.dap.adapter.executable [server]', executable, 'table')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.executable.command [server]', executable.command, 'string')
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.executable.args [server]', executable.args, 'table', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.name [server]', adapter.name, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.host [server]', adapter.host, 'string', true)
    if not ok then
      return false, err
    end
    ok, err = validate('rustaceanvim.dap.adapter.port [server]', adapter.port, 'string')
    if not ok then
      return false, err
    end
  else
    ok = false
    err =
      'rustaceanvim.dap.adapter:\nExpected rustaceanvim.dap.executable.Config, rustaceanvim.dap.server.Config or false'
  end
  if not ok then
    return false, err
  end
  return true
end

---@param callback fun(msg: string)
function M.check_for_lspconfig_conflict(callback)
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = 'FileType', pattern = 'rust' }) do
    if
      autocmd.group_name
      and autocmd.group_name == 'lspconfig'
      and autocmd.desc
      and autocmd.desc:match('rust_analyzer')
    then
      callback([[
nvim-lspconfig.rust_analyzer has been setup.
This will likely lead to conflicts with the rustaceanvim LSP client.
See ':h rustaceanvim.mason'
]])
      return
    end
  end
end

return M
