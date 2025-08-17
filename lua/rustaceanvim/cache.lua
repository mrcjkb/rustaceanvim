local M = {}

-- Nextest profile used to generate junit reports (needs to be written to a toml file)
local NEXTEST_CONFIG = [[# profile used to generate junit reports when in nextest mode
[profile.rustaceanvim.junit]
path = "junit.xml"
store-failure-output = true
store-success-output = true
]]

---@return string path to nextest.toml file
function M.nextest_config_path()
  local cache_dir = vim.fs.joinpath(vim.fn.stdpath('cache'), 'rustaceanvim')
  local config_path = vim.fs.joinpath(cache_dir, 'nextest.toml')

  vim.schedule(function()
    vim.notify('Creating nextest config file: ' .. config_path)
  end)

  -- Check if file already exists
  local stat = vim.uv.fs_stat(config_path)
  if stat and stat.type == 'file' then
    return config_path
  end

  -- Create cache directory if it doesn't exist
  vim.fn.mkdir(cache_dir, 'p')

  -- Write the config file
  local file = io.open(config_path, 'w')
  if not file then
    error('Failed to create nextest config file: ' .. config_path)
  end

  file:write(NEXTEST_CONFIG)
  file:close()

  return config_path
end

return M
