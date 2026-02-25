local M = {}

--- Nextest profile used to generate junit reports (needs to be written to a toml file)
--- IMPORTANT: When modifying this config, increment the revision suffix in the file name below!
local NEXTEST_CONFIG = [[# profile used to generate junit reports when in nextest mode
[profile.rustaceanvim.junit]
path = "junit.xml"
store-failure-output = true
store-success-output = true
]]

---@return string path to nextest.toml file
function M.nextest_config_path()
  local nvim_cache_dir = vim.fn.stdpath('cache') ---@as string
  local rustaceanvim_cache_dir = vim.fs.joinpath(nvim_cache_dir, 'rustaceanvim')
  local config_path = vim.fs.joinpath(rustaceanvim_cache_dir, 'nextest_1.toml')

  -- Check if file already exists
  local stat = vim.uv.fs_stat(config_path)
  if stat then
    return config_path
  end

  -- Create cache directory if it doesn't exist
  vim.fn.mkdir(rustaceanvim_cache_dir, 'p')

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
