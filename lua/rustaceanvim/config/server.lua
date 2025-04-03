---@mod rustaceanvim.config.server LSP configuration utility

local server = {}

---@class rustaceanvim.LoadRASettingsOpts
---
---Default settings to merge the loaded settings into.
---@field default_settings table|nil

--- Load rust-analyzer settings from a JSON file,
--- falling back to the default settings if none is found or if it cannot be decoded.
---@param _ string|nil The project root (ignored)
---@param opts rustaceanvim.LoadRASettingsOpts|nil
---@return table server_settings
---@see https://rust-analyzer.github.io/book/configuration
function server.load_rust_analyzer_settings(_, opts)
  local config = require('rustaceanvim.config.internal')

  local default_opts = { settings_file_pattern = 'rust-analyzer.json' }
  opts = vim.tbl_deep_extend('force', {}, default_opts, opts or {})
  local settings = opts.default_settings or config.server.default_settings
  local use_clippy = config.tools.enable_clippy and vim.fn.executable('cargo-clippy') == 1
  ---@diagnostic disable-next-line: undefined-field
  if
    settings['rust-analyzer'].check == nil
    and use_clippy
    and type(settings['rust-analyzer'].checkOnSave) ~= 'table'
  then
    ---@diagnostic disable-next-line: inject-field
    settings['rust-analyzer'].check = {
      command = 'clippy',
      extraArgs = { '--no-deps' },
    }
    if type(settings['rust-analyzer'].checkOnSave) ~= 'boolean' then
      ---@diagnostic disable-next-line: inject-field
      settings['rust-analyzer'].checkOnSave = true
    end
  end
  return settings
end

---@return lsp.ClientCapabilities
function server.create_client_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- send actions with hover request
  capabilities.experimental = {
    hoverActions = true,
    colorDiagnosticOutput = true,
    hoverRange = true,
    serverStatusNotification = true,
    snippetTextEdit = true,
    codeActionGroup = true,
    ssr = true,
  }

  -- enable auto-import
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  -- rust analyzer goodies
  local experimental_commands = {
    'rust-analyzer.runSingle',
    'rust-analyzer.showReferences',
    'rust-analyzer.gotoLocation',
    'editor.action.triggerParameterHints',
  }
  if package.loaded['dap'] ~= nil then
    table.insert(experimental_commands, 'rust-analyzer.debugSingle')
  end

  ---@diagnostic disable-next-line: inject-field
  capabilities.experimental.commands = {
    commands = experimental_commands,
  }

  return capabilities
end

return server
