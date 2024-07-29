local rust_analyzer = require('rustaceanvim.rust_analyzer')
local os = require('rustaceanvim.os')

local cargo = {}

---Checks if there is an active client for file_name and returns its root directory if found.
---@param file_name string
---@return string | nil root_dir The root directory of the active client for file_name (if there is one)
local function get_mb_active_client_root(file_name)
  ---@diagnostic disable-next-line: missing-parameter
  local cargo_home = vim.uv.os_getenv('CARGO_HOME') or vim.fs.joinpath(vim.env.HOME, '.cargo')
  local registry = vim.fs.joinpath(cargo_home, 'registry', 'src')
  local checkouts = vim.fs.joinpath(cargo_home, 'git', 'checkouts')

  ---@diagnostic disable-next-line: missing-parameter
  local rustup_home = vim.uv.os_getenv('RUSTUP_HOME') or vim.fs.joinpath(vim.env.HOME, '.rustup')
  local toolchains = vim.fs.joinpath(rustup_home, 'toolchains')

  for _, item in ipairs { toolchains, registry, checkouts } do
    item = os.normalize_path_on_windows(item)
    if file_name:sub(1, #item) == item then
      local clients = rust_analyzer.get_active_rustaceanvim_clients()
      return clients and #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

---Attempts to find the root for an existing active client. If no existing
---client root is found, returns the result of evaluating `config.root_dir`.
---@param config rustaceanvim.lsp.ClientConfig
---@param file_name string
---@return string | nil root_dir
function cargo.get_config_root_dir(config, file_name)
  local reuse_active = get_mb_active_client_root(file_name)
  if reuse_active then
    return reuse_active
  end

  local config_root_dir = config.root_dir
  if type(config_root_dir) == 'function' then
    return config_root_dir(file_name, cargo.get_root_dir)
  else
    return config_root_dir
  end
end

---@param path string The directory to search upward from
---@return string? cargo_crate_dir
---@return table? cargo_metadata
local function get_cargo_metadata(path)
  ---@diagnostic disable-next-line: missing-fields
  local cargo_crate_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, {
    upward = true,
    path = path,
  })[1])
  if vim.fn.executable('cargo') ~= 1 then
    return cargo_crate_dir
  end
  local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
  if cargo_crate_dir ~= nil then
    cmd[#cmd + 1] = '--manifest-path'
    cmd[#cmd + 1] = vim.fs.joinpath(cargo_crate_dir, 'Cargo.toml')
  end
  local sc = vim
    .system(cmd, {
      cwd = vim.uv.fs_stat(path) and path or cargo_crate_dir or vim.fn.getcwd(),
    })
    :wait()
  if sc.code ~= 0 then
    return cargo_crate_dir
  end
  local ok, cargo_metadata_json = pcall(vim.fn.json_decode, sc.stdout)
  if ok and cargo_metadata_json then
    return cargo_crate_dir, cargo_metadata_json
  end
  return cargo_crate_dir
end

---@param buf_name? string
---@return string edition
function cargo.get_rustc_edition(buf_name)
  local config = require('rustaceanvim.config.internal')
  ---@diagnostic disable-next-line: undefined-field
  if config.tools.rustc.edition then
    vim.deprecate('vim.g.rustaceanvim.config.tools.edition', 'default_edition', '6.0.0', 'rustaceanvim')
    ---@diagnostic disable-next-line: undefined-field
    return config.tools.rustc.edition
  end
  buf_name = buf_name or vim.api.nvim_buf_get_name(0)
  local path = vim.fs.dirname(buf_name)
  local _, cargo_metadata = get_cargo_metadata(path)
  local default_edition = config.tools.rustc.default_edition
  if not cargo_metadata then
    return default_edition
  end
  local package = vim.iter(cargo_metadata.packages or {}):find(function(pkg)
    return type(pkg.edition) == 'string'
  end)
  return package and package.edition or default_edition
end

---The default implementation used for `vim.g.rustaceanvim.server.root_dir`
---@param file_name string
---@return string | nil root_dir
function cargo.get_root_dir(file_name)
  local path = file_name:find('%.rs$') and vim.fs.dirname(file_name) or file_name
  if not path then
    return nil
  end
  local cargo_crate_dir, cargo_metadata = get_cargo_metadata(path)
  return cargo_metadata and cargo_metadata.workspace_root
    or cargo_crate_dir
    ---@diagnostic disable-next-line: missing-fields
    or vim.fs.dirname(vim.fs.find({ 'rust-project.json' }, {
      upward = true,
      path = path,
    })[1])
end

return cargo
