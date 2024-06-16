local M = {}
---@type RustaceanConfig
local config = require('rustaceanvim.config.internal')
local compat = require('rustaceanvim.compat')
local types = require('rustaceanvim.types.internal')
local rust_analyzer = require('rustaceanvim.rust_analyzer')
local server_status = require('rustaceanvim.server_status')
local cargo = require('rustaceanvim.cargo')
local os = require('rustaceanvim.os')

local function override_apply_text_edits()
  local old_func = vim.lsp.util.apply_text_edits
  ---@diagnostic disable-next-line
  vim.lsp.util.apply_text_edits = function(edits, bufnr, offset_encoding)
    local overrides = require('rustaceanvim.overrides')
    overrides.snippet_text_edits_to_text_edits(edits)
    old_func(edits, bufnr, offset_encoding)
  end
end

---@param client lsp.Client
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
  local results = vim.fn.glob(compat.joinpath(vscode_dir, 'settings.json'), true, true)
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
---@param server_cfg LspStartConfig LSP start settings
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

---@class LspStartConfig: RustaceanLspClientConfig
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
  local client_config = config.server
  ---@type LspStartConfig
  local lsp_start_config = vim.tbl_deep_extend('force', {}, client_config)
  local root_dir = cargo.get_config_root_dir(client_config, bufname)
  if not root_dir then
    --- No project root found. Start in detached/standalone mode.
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
      client.rpc.notify('workspace/didChangeWorkspaceFolders', params)
      if not client.workspace_folders then
        client.workspace_folders = {}
      end
      table.insert(client.workspace_folders, workspace_folder)
      vim.lsp.buf_attach_client(bufnr, client.id)
      return
    end
  end

  local rust_analyzer_cmd = types.evaluate(client_config.cmd)
  if #rust_analyzer_cmd == 0 or vim.fn.executable(rust_analyzer_cmd[1]) ~= 1 then
    vim.notify('rust-analyzer binary not found.', vim.log.levels.ERROR)
    return
  end
  ---@cast rust_analyzer_cmd string[]
  lsp_start_config.cmd = rust_analyzer_cmd
  lsp_start_config.name = 'rust-analyzer'
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

  return vim.lsp.start(lsp_start_config)
end

---Stop the LSP client.
---@param bufnr? number The buffer number, defaults to the current buffer
---@return table[] clients A list of clients that will be stopped
M.stop = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = rust_analyzer.get_active_rustaceanvim_clients(bufnr)
  vim.lsp.stop_client(clients)
  if type(clients) == 'table' then
    ---@cast clients lsp.Client[]
    for _, client in ipairs(clients) do
      server_status.reset_client_state(client.id)
    end
  else
    ---@cast clients lsp.Client
    server_status.reset_client_state(clients.id)
  end
  return clients
end

---Reload settings for the LSP client.
---@param bufnr? number The buffer number, defaults to the current buffer
---@return table[] clients A list of clients that will be have their settings reloaded
M.reload_settings = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = rust_analyzer.get_active_rustaceanvim_clients(bufnr)
  ---@cast clients lsp.Client[]
  for _, client in ipairs(clients) do
    local settings = get_start_settings(vim.api.nvim_buf_get_name(bufnr), client.config.root_dir, config.server)
    ---@diagnostic disable-next-line: inject-field
    client.settings = settings
    client.notify('workspace/didChangeConfiguration', {
      settings = client.settings,
    })
  end
  return clients
end

---Restart the LSP client.
---Fails silently if the buffer's filetype is not one of the filetypes specified in the config.
---@param bufnr? number The buffer number (optional), defaults to the current buffer
---@return number|nil client_id The LSP client ID after restart
M.restart = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local clients = M.stop(bufnr)
  local timer, _, _ = compat.uv.new_timer()
  if not timer then
    -- TODO: Log error when logging is implemented
    return
  end
  local attempts_to_live = 50
  local stopped_client_count = 0
  timer:start(200, 100, function()
    for _, client in ipairs(clients) do
      if client:is_stopped() then
        stopped_client_count = stopped_client_count + 1
        vim.schedule(function()
          M.start(bufnr)
        end)
      end
    end
    if stopped_client_count >= #clients then
      timer:stop()
      attempts_to_live = 0
    elseif attempts_to_live <= 0 then
      vim.notify('rustaceanvim.lsp: Could not restart all LSP clients.', vim.log.levels.ERROR)
      timer:stop()
      attempts_to_live = 0
    end
    attempts_to_live = attempts_to_live - 1
  end)
end

---@enum RustAnalyzerCmd
local RustAnalyzerCmd = {
  start = 'start',
  stop = 'stop',
  restart = 'restart',
  reload_settings = 'reloadSettings',
}

local function rust_analyzer_cmd(opts)
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
  end
end

vim.api.nvim_create_user_command('RustAnalyzer', rust_analyzer_cmd, {
  nargs = '+',
  desc = 'Starts or stops the rust-analyzer LSP client',
  complete = function(arg_lead, cmdline, _)
    local clients = rust_analyzer.get_active_rustaceanvim_clients()
    ---@type RustAnalyzerCmd[]
    local commands = #clients == 0 and { 'start' } or { 'stop', 'restart', 'reloadSettings' }
    if cmdline:match('^RustAnalyzer%s+%w*$') then
      return vim.tbl_filter(function(command)
        return command:find(arg_lead) ~= nil
      end, commands)
    end
  end,
})

return M
