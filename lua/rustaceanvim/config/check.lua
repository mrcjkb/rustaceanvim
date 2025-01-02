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
---@param cfg rustaceanvim.Config
---@return boolean is_valid
---@return string|nil error_message
function M.validate(cfg)
  local ok, err
  ok, err = validate('rustaceanvim', {
    tools = { cfg.tools, 'table' },
    server = { cfg.server, 'table' },
    dap = { cfg.dap, 'table' },
  })
  if not ok then
    return false, err
  end
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
    replace_builtin_hover = { hover_actions.replace_builtin_hover, 'boolean' },
  })
  if not ok then
    return false, err
  end
  local code_actions = tools.code_actions
  ok, err = validate('tools.code_actions', {
    group_icon = { code_actions.group_icon, 'string' },
    ui_select_fallback = { code_actions.ui_select_fallback, 'boolean' },
    keys = { code_actions.keys, 'table' },
  })
  if not ok then
    return false, err
  end
  local keys = code_actions.keys
  ok, err = validate('tools.code_actions.keys', {
    confirm = { keys.confirm, { 'table', 'string' } },
    quit = { keys.quit, { 'table', 'string' } },
  })
  if not ok then
    return false, err
  end
  local float_win_config = tools.float_win_config
  ok, err = validate('tools.float_win_config', {
    auto_focus = { float_win_config.auto_focus, 'boolean' },
    open_split = { float_win_config.open_split, 'string' },
  })
  if not ok then
    return false, err
  end
  local rustc = tools.rustc
  ok, err = validate('tools.rustc', {
    default_edition = { rustc.default_edition, 'string' },
  })
  if not ok then
    return false, err
  end
  ok, err = validate('tools', {
    executor = { tools.executor, { 'table', 'string' } },
    test_executor = { tools.test_executor, { 'table', 'string' } },
    crate_test_executor = { tools.crate_test_executor, { 'table', 'string' } },
    cargo_override = { tools.cargo_override, 'string', true },
    enable_nextest = { tools.enable_nextest, 'boolean' },
    enable_clippy = { tools.enable_clippy, 'boolean' },
    on_initialized = { tools.on_initialized, 'function', true },
    reload_workspace_from_cargo_toml = { tools.reload_workspace_from_cargo_toml, 'boolean' },
    open_url = { tools.open_url, 'function' },
  })
  if not ok then
    return false, err
  end
  local server = cfg.server
  ok, err = validate('server', {
    cmd = { server.cmd, { 'function', 'table' } },
    standalone = { server.standalone, 'boolean' },
    settings = { server.settings, { 'function', 'table' }, true },
    root_dir = { server.root_dir, { 'function', 'string' } },
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
    ---@cast adapter rustaceanvim.dap.executable.Config
    ok, err = validate('dap.adapter', {
      command = { adapter.command, 'string' },
      name = { adapter.name, 'string', true },
      args = { adapter.args, 'table', true },
    })
  elseif adapter.type == 'server' then
    ---@cast adapter rustaceanvim.dap.server.Config
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
