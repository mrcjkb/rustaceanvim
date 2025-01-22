---@mod rustaceanvim.config.server LSP configuration utility

local server = {}

---@class rustaceanvim.LoadRASettingsOpts
---
---(deprecated) File name or pattern to search for. Defaults to 'rust-analyzer.json'
---@field settings_file_pattern string|nil
---Default settings to merge the loaded settings into.
---@field default_settings table|nil

--- Load rust-analyzer settings from a JSON file,
--- falling back to the default settings if none is found or if it cannot be decoded.
---@param project_root string|nil The project root
---@param opts rustaceanvim.LoadRASettingsOpts|nil
---@return table server_settings
---@see https://rust-analyzer.github.io/manual.html#configuration
function server.load_rust_analyzer_settings(project_root, opts)
  local config = require('rustaceanvim.config.internal')
  local os = require('rustaceanvim.os')

  local default_opts = { settings_file_pattern = 'rust-analyzer.json' }
  opts = vim.tbl_deep_extend('force', {}, default_opts, opts or {})
  local default_settings = opts.default_settings or config.server.default_settings
  local use_clippy = config.tools.enable_clippy and vim.fn.executable('cargo-clippy') == 1
  ---@diagnostic disable-next-line: undefined-field
  if
    default_settings['rust-analyzer'].check == nil
    and use_clippy
    and type(default_settings['rust-analyzer'].checkOnSave) ~= 'table'
  then
    ---@diagnostic disable-next-line: inject-field
    default_settings['rust-analyzer'].check = {
      command = 'clippy',
      extraArgs = { '--no-deps' },
    }
    if type(default_settings['rust-analyzer'].checkOnSave) ~= 'boolean' then
      ---@diagnostic disable-next-line: inject-field
      default_settings['rust-analyzer'].checkOnSave = true
    end
  end
  if not project_root then
    return default_settings
  end
  local results = vim.fn.glob(vim.fs.joinpath(project_root, opts.settings_file_pattern), true, true)
  if #results == 0 then
    return default_settings
  end
  vim.deprecate('rust-analyzer.json', "'.vscode/settings.json' or ':h exrc'", '6.0.0', 'rustaceanvim')
  local config_json = results[1]
  local content = os.read_file(config_json)
  if not content then
    vim.notify('Could not read ' .. config_json, vim.log.levels.WARN)
    return default_settings
  end
  local json = require('rustaceanvim.config.json')
  local rust_analyzer_settings = json.silent_decode(content)
  local ra_key = 'rust-analyzer'
  local has_ra_key = false
  for key, _ in pairs(rust_analyzer_settings) do
    if key:find(ra_key) ~= nil then
      has_ra_key = true
      break
    end
  end
  if has_ra_key then
    -- Settings json with "rust-analyzer" key
    json.override_with_rust_analyzer_json_keys(default_settings, rust_analyzer_settings)
  else
    -- "rust-analyzer" settings are top level
    json.override_with_json_keys(default_settings, rust_analyzer_settings)
  end
  return default_settings
end

---@return lsp.ClientCapabilities
local function make_rustaceanvim_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  if vim.fn.has('nvim-0.10.0') == 1 then
    -- snippets
    -- This will also be added if cmp_nvim_lsp is detected.
    capabilities.textDocument.completion.completionItem.snippetSupport = true
  end

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

  capabilities.experimental.commands = {
    commands = experimental_commands,
  }

  return capabilities
end

---@param mod_name string
---@param callback fun(mod: table): lsp.ClientCapabilities
---@return lsp.ClientCapabilities
local function mk_capabilities_if_available(mod_name, callback)
  local available, mod = pcall(require, mod_name)
  if available and type(mod) == 'table' then
    local ok, capabilities = pcall(callback, mod)
    if ok then
      return capabilities
    end
  end
  return {}
end

---@return lsp.ClientCapabilities
function server.create_client_capabilities()
  local rs_capabilities = make_rustaceanvim_capabilities()
  local blink_capabilities = mk_capabilities_if_available('blink.cmp', function(blink)
    return blink.get_lsp_capabilities()
  end)
  local cmp_capabilities = mk_capabilities_if_available('cmp_nvim_lsp', function(cmp_nvim_lsp)
    return cmp_nvim_lsp.default_capabilities()
  end)
  local selection_range_capabilities = mk_capabilities_if_available('lsp-selection-range', function(lsp_selection_range)
    return lsp_selection_range.update_capabilities {}
  end)
  local folding_range_capabilities = mk_capabilities_if_available('ufo', function(_)
    return {
      textDocument = {
        foldingRange = {
          dynamicRegistration = false,
          lineFoldingOnly = true,
        },
      },
    }
  end)
  return vim.tbl_deep_extend(
    'force',
    rs_capabilities,
    blink_capabilities,
    cmp_capabilities,
    selection_range_capabilities,
    folding_range_capabilities
  )
end

return server
