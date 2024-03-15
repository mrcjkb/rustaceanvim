---@mod rustaceanvim.config.server LSP configuration utility

local server = {}

---@class LoadRASettingsOpts
---@field settings_file_pattern string|nil File name or pattern to search for. Defaults to 'rust-analyzer.json'
---@field default_settings table|nil Default settings to merge the loaded settings into

--- Load rust-analyzer settings from a JSON file,
--- falling back to the default settings if none is found or if it cannot be decoded.
---@param project_root string|nil The project root
---@param opts LoadRASettingsOpts|nil
---@return table server_settings
---@see https://rust-analyzer.github.io/manual.html#configuration
function server.load_rust_analyzer_settings(project_root, opts)
  local config = require('rustaceanvim.config.internal')
  local compat = require('rustaceanvim.compat')
  local os = require('rustaceanvim.os')

  local default_opts = { settings_file_pattern = 'rust-analyzer.json' }
  opts = vim.tbl_deep_extend('force', {}, default_opts, opts or {})
  local default_settings = opts.default_settings or config.server.default_settings
  local use_clippy = config.tools.enable_clippy and vim.fn.executable('cargo-clippy') == 1
  ---@diagnostic disable-next-line: undefined-field
  if default_settings['rust-analyzer'].checkOnSave == nil and use_clippy then
    ---@diagnostic disable-next-line: inject-field
    default_settings['rust-analyzer'].checkOnSave = {
      allFeatures = true,
      command = 'clippy',
      extraArgs = { '--no-deps' },
    }
  end
  if not project_root then
    return default_settings
  end
  local results = vim.fn.glob(compat.joinpath(project_root, opts.settings_file_pattern), true, true)
  if #results == 0 then
    return default_settings
  end
  local config_json = results[1]
  local content = os.read_file(config_json)
  if not content then
    vim.notify('Could not read ' .. config_json, vim.log.levels.WARNING)
    return default_settings
  end
  local json = require('rustaceanvim.config.json')
  local rust_analyzer_settings = json.silent_decode(content)
  local ra_key = 'rust-analyzer'
  local has_ra_key = true
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

return server
