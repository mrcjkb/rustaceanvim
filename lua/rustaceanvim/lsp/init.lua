local M = {}
---@type rustaceanvim.Config
local config = require('rustaceanvim.config.internal')
local types = require('rustaceanvim.types.internal')
local rust_analyzer = require('rustaceanvim.rust_analyzer')
local server_status = require('rustaceanvim.server_status')
local cargo = require('rustaceanvim.cargo')
local os = require('rustaceanvim.os')
local rustc = require('rustaceanvim.rustc')
local compat = require('rustaceanvim.compat')

local ra_client_name = 'rust-analyzer'

local function override_apply_text_edits()
  local old_func = vim.lsp.util.apply_text_edits
  ---@diagnostic disable-next-line
  vim.lsp.util.apply_text_edits = function(edits, bufnr, offset_encoding)
    local overrides = require('rustaceanvim.overrides')
    overrides.snippet_text_edits_to_text_edits(edits)
    old_func(edits, bufnr, offset_encoding or 'utf-8')
  end
end

---@param client vim.lsp.Client
---@param root_dir string
---@return boolean
local function is_in_workspace(client, root_dir)
  if not client.workspace_folders then
    return false
  end

  for _, dir in ipairs(client.workspace_folders) do
    if (root_dir .. '/'):sub(1, #dir.name + 1) == dir.name .. '/' then
      return true
    end
  end

  return false
end

---Searches upward for a .vscode/settings.json that contains rust-analyzer
---settings and returns them.
---@param bufname string
---@return table server_settings or an empty table if no settings were found
local function find_vscode_settings(bufname)
  local settings = {}
  local found_dirs = vim.fs.find({ '.vscode' }, { upward = true, path = vim.fs.dirname(bufname), type = 'directory' })
  if vim.tbl_isempty(found_dirs) then
    return settings
  end
  local vscode_dir = found_dirs[1]
  local results = vim.fn.glob(vim.fs.joinpath(vscode_dir, 'settings.json'), true, true)
  if vim.tbl_isempty(results) then
    return settings
  end
  local content = os.read_file(results[1])
  return content and require('rustaceanvim.config.json').silent_decode(content) or {}
end

---Generate the settings from config and vscode settings if found.
---settings and returns them.
---@param bufname string
---@param root_dir string | nil
---@param client_config table
---@return table server_settings or an empty table if no settings were found
local function get_start_settings(bufname, root_dir, client_config)
  local settings = client_config.settings
  local evaluated_settings = type(settings) == 'function' and settings(root_dir, client_config.default_settings)
    or settings

  if config.server.load_vscode_settings then
    local json_settings = find_vscode_settings(bufname)
    require('rustaceanvim.config.json').override_with_rust_analyzer_json_keys(evaluated_settings, json_settings)
  end

  return evaluated_settings
end

---HACK: Workaround for https://github.com/neovim/neovim/pull/28690
--- to solve #423.
--- Checks if Neovim's file watcher is enabled, and if it isn't,
--- configures rust-analyzer to enable server-side file watching (if not configured otherwise).
---
---@param server_cfg rustaceanvim.lsp.StartConfig LSP start settings
local function configure_file_watcher(server_cfg)
  local is_client_file_watcher_enabled =
    vim.tbl_get(server_cfg.capabilities, 'workspace', 'didChangeWatchedFiles', 'dynamicRegistration')
  local file_watcher_setting = vim.tbl_get(server_cfg.settings, 'rust-analyzer', 'files', 'watcher')
  if is_client_file_watcher_enabled and not file_watcher_setting then
    server_cfg.settings = vim.tbl_deep_extend('force', server_cfg.settings, {
      ['rust-analyzer'] = {
        files = {
          watcher = 'server',
        },
      },
    })
  end
end

---LSP restart internal implementations
---@param bufnr? number The buffer number, defaults to the current buffer
---@param filter? rustaceanvim.lsp.get_clients.Filter
---@param callback? fun(client: vim.lsp.Client) Optional callback to run for each client before restarting.
---@return number|nil client_id
local function restart(bufnr, filter, callback)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.stop(bufnr, filter)
  local timer, _, _ = vim.uv.new_timer()
  if not timer then
    vim.schedule(function()
      vim.notify('rustaceanvim.lsp: Failed to initialise timer for LSP client restart.', vim.log.levels.ERROR)
    end)
    return
  end
  local max_attempts = 50
  local attempts_to_live = max_attempts
  local stopped_client_count = 0
  timer:start(200, 100, function()
    for _, client in ipairs(clients) do
      if compat.client_is_stopped(client) then
        stopped_client_count = stopped_client_count + 1
        vim.schedule(function()
          -- Execute the callback, if provided, for additional actions before restarting
          if callback then
            callback(client)
          end
          M.start(bufnr)
        end)
      end
    end
    if stopped_client_count >= #clients then
      timer:stop()
      attempts_to_live = 0
    elseif attempts_to_live <= 0 then
      vim.schedule(function()
        vim.notify(
          ('rustaceanvim.lsp: Could not restart all LSP clients after %d attempts.'):format(max_attempts),
          vim.log.levels.ERROR
        )
      end)
      timer:stop()
      attempts_to_live = 0
    end
    attempts_to_live = attempts_to_live - 1
  end)
end

---@class rustaceanvim.lsp.StartConfig: rustaceanvim.lsp.ClientConfig
---@field root_dir string | nil
---@field init_options? table
---@field settings table
---@field cmd string[]
---@field name string
---@field filetypes string[]
---@field capabilities table
---@field handlers lsp.Handler[]
---@field on_init function
---@field on_attach function
---@field on_exit function

--- Start or attach the LSP client
---@param bufnr? number The buffer number (optional), defaults to the current buffer
---@return integer|nil client_id The LSP client ID
M.start = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local ra_config = type(vim.lsp.config) == 'table' and vim.lsp.config[ra_client_name] or {}
  local client_config = vim.tbl_deep_extend('force', config.server, ra_config)
  ---@type rustaceanvim.lsp.StartConfig
  local lsp_start_config = vim.tbl_deep_extend('force', {}, client_config)
  local root_dir = cargo.get_config_root_dir(client_config, bufname)
  if not root_dir then
    vim.notify(
      [[
rustaceanvim:
No project root found.
Starting rust-analyzer client in detached/standalone mode (with reduced functionality).
]],
      vim.log.levels.INFO
    )
    root_dir = vim.fs.dirname(bufname)
    lsp_start_config.init_options = { detachedFiles = { bufname } }
  end
  root_dir = os.normalize_path_on_windows(root_dir)
  lsp_start_config.root_dir = root_dir

  lsp_start_config.settings = get_start_settings(bufname, root_dir, client_config)
  configure_file_watcher(lsp_start_config)

  -- Check if a client is already running and add the workspace folder if necessary.
  for _, client in pairs(rust_analyzer.get_active_rustaceanvim_clients()) do
    if root_dir and not is_in_workspace(client, root_dir) then
      local workspace_folder = { uri = vim.uri_from_fname(root_dir), name = root_dir }
      local params = {
        event = {
          added = { workspace_folder },
          removed = {},
        },
      }
      compat.client_notify(client, 'workspace/didChangeWorkspaceFolders', params)
      if not client.workspace_folders then
        client.workspace_folders = {}
      end
      table.insert(client.workspace_folders, workspace_folder)
      vim.lsp.buf_attach_client(bufnr, client.id)
      return
    end
  end

  local rust_analyzer_cmd = types.evaluate(client_config.cmd)

  local ra_multiplex = lsp_start_config.ra_multiplex
  if ra_multiplex.enable then
    local ok, running_ra_multiplex = pcall(function()
      local result = vim.system({ 'pgrep', 'ra-multiplex' }):wait().code
      return result == 0
    end)
    if ok and running_ra_multiplex then
      rust_analyzer_cmd = vim.lsp.rpc.connect(ra_multiplex.host, ra_multiplex.port)
      local ra_settings = lsp_start_config.settings['rust-analyzer'] or {}
      ra_settings.lspMux = ra_settings.lspMux
        or {
          version = '1',
          method = 'connect',
          server = 'rust-analyzer',
        }
      lsp_start_config.settings['rust-analyzer'] = ra_settings
    end
  end

  -- special case: rust-analyzer has a `rust-analyzer.server.path` config option
  -- that allows you to override the path via .vscode/settings.json
  local server_path = vim.tbl_get(lsp_start_config.settings, 'rust-analyzer', 'server', 'path')
  if type(server_path) == 'string' then
    if type(rust_analyzer_cmd) == 'table' then
      rust_analyzer_cmd[1] = server_path
    else
      rust_analyzer_cmd = { server_path }
    end
    --
  end
  if type(rust_analyzer_cmd) == 'table' then
    if #rust_analyzer_cmd == 0 then
      vim.schedule(function()
        vim.notify('rust-analyzer command is not set!', vim.log.levels.ERROR)
      end)
      return
    end
    if vim.fn.executable(rust_analyzer_cmd[1]) ~= 1 then
      vim.schedule(function()
        vim.notify(('%s is not executable'):format(rust_analyzer_cmd[1]), vim.log.levels.ERROR)
      end)
      return
    end
  end
  ---@cast rust_analyzer_cmd string[]
  lsp_start_config.cmd = rust_analyzer_cmd
  lsp_start_config.name = ra_client_name
  lsp_start_config.filetypes = { 'rust' }

  local custom_handlers = {}
  custom_handlers['experimental/serverStatus'] = server_status.handler

  if config.tools.hover_actions.replace_builtin_hover then
    custom_handlers['textDocument/hover'] = require('rustaceanvim.hover_actions').handler
  end

  lsp_start_config.handlers = vim.tbl_deep_extend('force', custom_handlers, lsp_start_config.handlers or {})

  local commands = require('rustaceanvim.commands')
  local old_on_init = lsp_start_config.on_init
  lsp_start_config.on_init = function(...)
    override_apply_text_edits()
    commands.create_rust_lsp_command()
    if type(old_on_init) == 'function' then
      old_on_init(...)
    end
  end

  local old_on_attach = lsp_start_config.on_attach
  lsp_start_config.on_attach = function(...)
    if type(old_on_attach) == 'function' then
      old_on_attach(...)
    end
    if config.dap.autoload_configurations then
      -- When switching projects, there might be new debuggables (#466)
      require('rustaceanvim.commands.debuggables').add_dap_debuggables()
    end
  end

  local old_on_exit = lsp_start_config.on_exit
  lsp_start_config.on_exit = function(...)
    override_apply_text_edits()
    -- on_exit runs in_fast_event
    vim.schedule(function()
      commands.delete_rust_lsp_command()
    end)
    if type(old_on_exit) == 'function' then
      old_on_exit(...)
    end
  end

  -- rust-analyzer treats settings in initializationOptions specially -- in particular, workspace_discoverConfig
  -- so copy them to init_options (the vim name)
  -- so they end up in initializationOptions (the LSP name)
  -- ... and initialization_options (the rust name) in rust-analyzer's main.rs
  lsp_start_config.init_options = vim.tbl_deep_extend(
    'force',
    lsp_start_config.init_options or {},
    vim.tbl_get(lsp_start_config.settings, 'rust-analyzer')
  )

  return vim.lsp.start(lsp_start_config)
end

---Stop the LSP client.
---@param bufnr? number The buffer number, defaults to the current buffer
---@param filter? rustaceanvim.lsp.get_clients.Filter
---@return vim.lsp.Client[] clients A list of clients that will be stopped
M.stop = function(bufnr, filter)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = rust_analyzer.get_active_rustaceanvim_clients(bufnr, filter)
  vim.lsp.stop_client(clients)
  if type(clients) == 'table' then
    ---@cast clients vim.lsp.Client[]
    for _, client in ipairs(clients) do
      server_status.reset_client_state(client.id)
    end
  else
    ---@cast clients vim.lsp.Client
    server_status.reset_client_state(clients.id)
  end
  return clients
end

---Reload settings for the LSP client.
---@param bufnr? number The buffer number, defaults to the current buffer
---@return vim.lsp.Client[] clients A list of clients that will be have their settings reloaded
M.reload_settings = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = rust_analyzer.get_active_rustaceanvim_clients(bufnr)
  ---@cast clients vim.lsp.Client[]
  for _, client in ipairs(clients) do
    local settings = get_start_settings(vim.api.nvim_buf_get_name(bufnr), client.config.root_dir, config.server)
    ---@diagnostic disable-next-line: inject-field
    client.settings = settings
    compat.client_notify(client, 'workspace/didChangeConfiguration', {
      settings = client.settings,
    })
  end
  return clients
end

---Updates the target architecture setting for the LSP client associated with the given buffer.
---@param bufnr? number The buffer number, defaults to the current buffer
---@param target? string Cargo target triple (e.g., 'x86_64-unknown-linux-gnu') to set
M.set_target_arch = function(bufnr, target)
  target = target or rustc.DEFAULT_RUSTC_TARGET
  ---@param client vim.lsp.Client
  restart(bufnr, { exclude_rustc_target = target }, function(client)
    rustc.with_rustc_target_architectures(function(rustc_targets)
      if rustc_targets[target] then
        local ra = client.config.settings['rust-analyzer'] or {}
        ---@diagnostic disable-next-line: inject-field
        ra.cargo = ra.cargo or {}
        ra.cargo.target = target
        compat.client_notify(client, 'workspace/didChangeConfiguration', { settings = client.config.settings })
        return
      else
        vim.schedule(function()
          vim.notify('Invalid target architecture provided: ' .. tostring(target), vim.log.levels.ERROR)
        end)
        return
      end
    end)
  end)
end

---Restart the LSP client.
---Fails silently if the buffer's filetype is not one of the filetypes specified in the config.
---@return number|nil client_id The LSP client ID after restart
M.restart = function()
  return restart()
end

---@enum RustAnalyzerCmd
local RustAnalyzerCmd = {
  start = 'start',
  stop = 'stop',
  restart = 'restart',
  reload_settings = 'reloadSettings',
  target = 'target',
}

local function rust_analyzer_user_cmd(opts)
  local fargs = opts.fargs
  local cmd = fargs[1]
  ---@cast cmd RustAnalyzerCmd
  if cmd == RustAnalyzerCmd.start then
    M.start()
  elseif cmd == RustAnalyzerCmd.stop then
    M.stop()
  elseif cmd == RustAnalyzerCmd.restart then
    M.restart()
  elseif cmd == RustAnalyzerCmd.reload_settings then
    M.reload_settings()
  elseif cmd == RustAnalyzerCmd.target then
    local target_arch = fargs[2]
    M.set_target_arch(nil, target_arch)
  end
end

vim.api.nvim_create_user_command('RustAnalyzer', rust_analyzer_user_cmd, {
  nargs = '+',
  desc = 'Starts, stops the rust-analyzer LSP client or changes the target',
  complete = function(arg_lead, cmdline, _)
    local clients = rust_analyzer.get_active_rustaceanvim_clients()
    ---@type RustAnalyzerCmd[]
    local commands = #clients == 0 and { 'start' } or { 'stop', 'restart', 'reloadSettings', 'target' }
    if cmdline:match('^RustAnalyzer%s+%w*$') then
      return vim.tbl_filter(function(command)
        return command:find(arg_lead) ~= nil
      end, commands)
    end
  end,
})

return M
