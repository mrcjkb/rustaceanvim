local rust_analyzer = require('rustaceanvim.rust_analyzer')
local os = require('rustaceanvim.os')

local cargo = {}

---@param path string The directory to search upward from
---@param callback? fun(cargo_crate_dir: string?, cargo_metadata: table?) If `nil`, this function runs synchronously
---@return string? cargo_crate_dir (if `callback ~= nil` and successful)
---@return table? cargo_metadata (if `callback ~= nil` and successful)
local function get_cargo_metadata(path, callback)
  ---@diagnostic disable-next-line: missing-fields
  local cargo_crate_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, {
    upward = true,
    path = path,
  })[1])
  if vim.fn.executable('cargo') ~= 1 then
    return callback and callback(cargo_crate_dir) or cargo_crate_dir
  end
  local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
  if cargo_crate_dir ~= nil then
    cmd[#cmd + 1] = '--manifest-path'
    cmd[#cmd + 1] = vim.fs.joinpath(cargo_crate_dir, 'Cargo.toml')
  end

  ---@param sc vim.SystemCompleted
  local function on_exit(sc)
    if sc.code ~= 0 then
      return callback and callback(cargo_crate_dir) or cargo_crate_dir
    end
    local ok, cargo_metadata_json = pcall(vim.fn.json_decode, sc.stdout)
    if ok and cargo_metadata_json then
      return callback and callback(cargo_crate_dir, cargo_metadata_json) or cargo_crate_dir, cargo_metadata_json
    else
      vim.notify(
        "rustaceanvim: Could not decode 'cargo metadata' output:\n" .. (cargo_metadata_json or 'unown error'),
        vim.log.levels.WARN
      )
    end
    return callback and callback(cargo_crate_dir) or cargo_crate_dir
  end

  if callback then
    vim.uv.fs_stat(path, function(_, stat)
      vim.system(cmd, {
        cwd = stat and path or cargo_crate_dir or vim.uv.cwd(),
      }, vim.schedule_wrap(on_exit))
    end)
  else
    local sc = vim
      .system(cmd, {
        cwd = vim.uv.fs_stat(path) and path or cargo_crate_dir or vim.fn.getcwd(),
      })
      :wait()
    return on_exit(sc)
  end
end

---The default implementation used for `vim.g.rustaceanvim.server.root_dir`
---@param file_name string
---@param callback? fun(root_dir: string | nil) If `nil`, this function runs synchronously
---@return string | nil root_dir (if `callback ~= nil` and successful)
local function default_get_root_dir(file_name, callback)
  local path = file_name:find('%.rs$') and vim.fs.dirname(file_name) or file_name
  if not path then
    return nil
  end

  ---@param cargo_crate_dir? string
  ---@param cargo_metadata? table
  ---@return string | nil root_dir
  local function root_dir(cargo_crate_dir, cargo_metadata)
    return cargo_metadata and cargo_metadata.workspace_root
      or cargo_crate_dir
      or vim.fs.dirname(vim.fs.find({ 'rust-project.json' }, {
        upward = true,
        path = path,
      })[1])
  end
  if callback then
    get_cargo_metadata(path, function(cargo_crate_dir, cargo_metadata)
      callback(root_dir(cargo_crate_dir, cargo_metadata))
    end)
  else
    local cargo_crate_dir, cargo_metadata = get_cargo_metadata(path)
    return root_dir(cargo_crate_dir, cargo_metadata)
  end
end

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
---@param callback? fun(root_dir: string?) If `nil`, this function runs synchronously
---@return string | nil root_dir
function cargo.get_config_root_dir(config, file_name, callback)
  local reuse_active = get_mb_active_client_root(file_name)
  if reuse_active then
    return callback and callback(reuse_active) or reuse_active
  end
  if type(config.root_dir) == 'function' then
    local root_dir = config.root_dir(file_name, default_get_root_dir)
    return callback and callback(root_dir) or root_dir
  elseif type(config.root_dir) == 'string' then
    local root_dir = config.root_dir
    ---@cast root_dir string
    return callback and callback(root_dir) or root_dir
  else
    return default_get_root_dir(file_name, callback)
  end
end

---@param callback fun(edition: string)
function cargo.get_rustc_edition(callback)
  local config = require('rustaceanvim.config.internal')
  local buf_name = vim.api.nvim_buf_get_name(0)
  local path = vim.fs.dirname(buf_name)
  get_cargo_metadata(path, function(_, cargo_metadata)
    local default_edition = config.tools.rustc.default_edition
    if not cargo_metadata then
      return callback(default_edition)
    end
    local pkg = vim.iter(cargo_metadata.packages or {}):find(function(p)
      return type(p.edition) == 'string'
    end)
    return callback(pkg and pkg.edition or default_edition)
  end)
end

return cargo
