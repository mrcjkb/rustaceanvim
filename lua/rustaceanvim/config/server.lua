---@mod rustaceanvim.config.server LSP configuration utility

local server = {}

---Read the content of a file
---@param filename string
---@return string|nil content
local function read_file(filename)
  local content
  local f = io.open(filename, 'r')
  if f then
    content = f:read('*a')
    f:close()
  end
  return content
end

---@class LoadRASettingsOpts
---@field settings_file_pattern string|nil File name or pattern to search for. Defaults to 'rust-analyzer.json'

--- Load rust-analyzer settings from a JSON file,
--- falling back to the default settings if none is found or if it cannot be decoded.
---@param project_root string|nil The project root
---@param opts LoadRASettingsOpts|nil
---@return table server_settings
---@see https://rust-analyzer.github.io/manual.html#configuration
function server.load_rust_analyzer_settings(project_root, opts)
  local config = require('rustaceanvim.config.internal')
  local compat = require('rustaceanvim.compat')

  local default_settings = config.server.default_settings
  if not project_root then
    return default_settings
  end
  local default_opts = { settings_file_pattern = 'rust-analyzer.json' }
  opts = vim.tbl_deep_extend('force', {}, default_opts, opts or {})
  local results = vim.fn.glob(compat.joinpath(project_root, opts.settings_file_pattern), true, true)
  if #results == 0 then
    return default_settings
  end
  local config_json = results[1]
  local content = read_file(config_json)
  local success, rust_analyzer_settings = pcall(vim.json.decode, content)
  if not success then
    local msg = 'Could not decode ' .. config_json .. '. Falling back to default settings.'
    vim.notify('rustaceanvim: ' .. msg, vim.log.levels.ERROR)
    return default_settings
  end
  default_settings['rust-analyzer'] = rust_analyzer_settings
  return default_settings
end

return server
