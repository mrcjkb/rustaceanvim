---@mod rustaceanvim.config.check rustaceanvim configuration check

local types = require('rustaceanvim.types.internal')

local M = {}

---@param path string
---@param msg string|nil
---@return string
local function mk_error_msg(path, msg)
  return msg and path .. '.' .. msg or path
end

---@param path string The config path
---@param tbl table The table to validate
---@see vim.validate
---@return boolean is_valid
---@return string|nil error_message
local function validate(path, tbl)
  local prefix = 'Invalid config: '
  local ok, err = pcall(vim.validate, tbl)
  return ok or false, prefix .. mk_error_msg(path, err)
end

---Validates the config.
---@param cfg RustaceanConfig
---@return boolean is_valid
---@return string|nil error_message
function M.validate(cfg)
  local ok, err
  local tools = cfg.tools
  local crate_graph = tools.crate_graph
  ok, err = validate('tools.crate_graph', {
    backend = { crate_graph.backend, 'string', true },
    enabled_graphviz_backends = { crate_graph.enabled_graphviz_backends, 'table', true },
    full = { crate_graph.full, 'boolean' },
    output = { crate_graph.output, 'string', true },
    pipe = { crate_graph.pipe, 'string', true },
  })
  if not ok then
    return false, err
  end
  local hover_actions = tools.hover_actions
  ok, err = validate('tools.hover_actions', {
    auto_focus = { hover_actions.auto_focus, 'boolean' },
    border = { hover_actions.border, 'table' },
    max_height = { hover_actions.max_height, 'number', true },
    max_width = { hover_actions.max_width, 'number', true },
    replace_builtin_hover = { hover_actions.replace_builtin_hover, 'boolean' },
  })
  if not ok then
    return false, err
  end
  ok, err = validate('tools', {
    executor = { tools.executor, { 'table', 'string' } },
    on_initialized = { tools.on_initialized, 'function', true },
    reload_workspace_from_cargo_toml = { tools.reload_workspace_from_cargo_toml, 'boolean' },
  })
  if not ok then
    return false, err
  end
  local server = cfg.server
  ok, err = validate('server', {
    cmd = { server.cmd, { 'function', 'table' } },
    standalone = { server.standalone, 'boolean' },
    settings = { server.settings, 'function', 'table', true },
  })
  if not ok then
    return false, err
  end
  if type(server.settings) == 'table' then
    ok, err = validate('server.settings', {
      ['rust-analyzer'] = { server.settings['rust-analyzer'], 'table', true },
    })
    if not ok then
      return false, err
    end
  end
  local dap = cfg.dap
  local adapter = types.evaluate(dap.adapter)
  if adapter == false then
    ok = true
  elseif adapter.type == 'executable' then
    ---@cast adapter DapExecutableConfig
    ok, err = validate('dap.adapter', {
      command = { adapter.command, 'string' },
      name = { adapter.name, 'string', true },
      args = { adapter.args, 'table', true },
    })
  elseif adapter.type == 'server' then
    ---@cast adapter DapServerConfig
    ok, err = validate('dap.adapter', {
      command = { adapter.executable, 'table' },
      name = { adapter.name, 'string', true },
      host = { adapter.host, 'string', true },
      port = { adapter.port, 'string' },
    })
    if ok then
      ok, err = validate('dap.adapter.executable', {
        command = { adapter.executable.command, 'string' },
        args = { adapter.executable.args, 'table', true },
      })
    end
  else
    ok = false
    err = 'dap.adapter: Expected DapExecutableConfig, DapServerConfig or false'
  end
  if not ok then
    return false, err
  end
  return true
end

return M
