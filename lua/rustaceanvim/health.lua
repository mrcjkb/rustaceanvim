---@mod rustaceanvim.health Health checks

local health = {}

local h = vim.health

---@class rustaceanvim.LuaDependency
---@field module string The name of a module
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information

---@type rustaceanvim.LuaDependency[]
local lua_dependencies = {
  {
    module = 'dap',
    optional = function()
      return true
    end,
    url = '[mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap)',
    info = 'Needed for debugging features',
  },
}

---@class rustaceanvim.ExternalDependency
---@field name string Name of the dependency
---@field get_binaries fun():string[] Function that returns the binaries to check for
---@field is_installed? fun(bin: string):boolean Default: `vim.fn.executable(bin) == 1`
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information
---@field extra_checks_if_installed? fun(bin: string) Optional extra checks to perform if the dependency is installed
---@field extra_checks_if_not_installed? fun() Optional extra checks to perform if the dependency is not installed

---@param dep rustaceanvim.LuaDependency
local function check_lua_dependency(dep)
  if pcall(require, dep.module) then
    h.ok(dep.url .. ' installed.')
    return
  end
  if dep.optional() then
    h.warn(('%s not installed. %s %s'):format(dep.module, dep.info, dep.url))
  else
    error(('Lua dependency %s not found: %s'):format(dep.module, dep.url))
  end
end

---@param dep rustaceanvim.ExternalDependency
---@return boolean is_installed
---@return string binary
---@return string version
local check_installed = function(dep)
  local binaries = dep.get_binaries()
  for _, binary in ipairs(binaries) do
    local is_executable = dep.is_installed or function(bin)
      return vim.fn.executable(bin) == 1
    end
    if is_executable(binary) then
      local handle = io.popen(binary .. ' --version')
      if handle then
        local binary_version, error_msg = handle:read('*a')
        handle:close()
        if error_msg then
          return false, binary, error_msg
        end
        return true, binary, binary_version
      end
      return false, binary, 'Unable to determine version.'
    end
  end
  return false, binaries[1], 'Could not find an executable binary.'
end

---@param dep rustaceanvim.ExternalDependency
local function check_external_dependency(dep)
  local is_installed, binary, version_or_err = check_installed(dep)
  if is_installed then
    ---@cast binary string
    local mb_version_newline_idx = version_or_err and version_or_err:find('\n')
    local mb_version_len = version_or_err
      and (mb_version_newline_idx and mb_version_newline_idx - 1 or version_or_err:len())
    version_or_err = version_or_err and version_or_err:sub(0, mb_version_len) or '(unknown version)'
    h.ok(('%s: found %s'):format(dep.name, version_or_err))
    if dep.extra_checks_if_installed then
      dep.extra_checks_if_installed(binary)
    end
    return
  end
  if dep.optional() then
    h.warn(([[
      %s: not found.
      Install %s for extended capabilities.
      %s
      ]]):format(dep.name, dep.url, dep.info))
  else
    error(([[
      %s: not found: %s
      rustaceanvim requires %s.
      %s
      ]]):format(dep.name, version_or_err, dep.url, dep.info))
  end
  if dep.extra_checks_if_not_installed then
    dep.extra_checks_if_not_installed()
  end
end

---@param config rustaceanvim.Config
local function check_config(config)
  h.start('Checking config')
  if vim.g.rustaceanvim and not config.was_g_rustaceanvim_sourced then
    error('vim.g.rustaceanvim is set, but it was sourced after rustaceanvim was initialized.')
  end
  local valid, err = require('rustaceanvim.config.check').validate(config)
  if valid then
    h.ok('No errors found in config.')
  else
    error(err or '' .. vim.g.rustaceanvim and '' or ' This looks like a plugin bug!')
  end
end

local function is_dap_enabled()
  if not pcall(require, 'dap') then
    return false
  end
  local rustaceanvim = vim.g.rustaceanvim or {}
  local opts = type(rustaceanvim) == 'function' and rustaceanvim() or rustaceanvim
  return vim.tbl_get(opts, 'dap', 'adapter') ~= false
end

local function check_for_conflicts()
  h.start('Checking for conflicting plugins')
  require('rustaceanvim.config.check').check_for_lspconfig_conflict(error)
  if package.loaded['rustaceanvim.neotest'] ~= nil and package.loaded['neotest-rust'] ~= nil then
    error('rustaceanvim.neotest and neotest-rust are both loaded. This is likely a conflict.')
    return
  end
  h.ok('No conflicting plugins detected.')
end

local function check_tree_sitter()
  h.start('Checking for tree-sitter parser')
  local has_tree_sitter_rust_parser = #vim.api.nvim_get_runtime_file('parser/rust.so', true) > 0
    or #vim.api.nvim_get_runtime_file('parser/rust.dll', true) > 0
  if has_tree_sitter_rust_parser then
    h.ok('tree-sitter parser for Rust detected.')
  else
    h.warn("No tree-sitter parser for Rust detected. Required by 'Rustc unpretty' command.")
  end
end

local function check_json_config()
  local json = require('rustaceanvim.config.json')
  if json.is_json_config_loaded() then
    local errors = json.get_errors()
    if #errors > 0 then
      h.warn('.vscode/settings.json failed to load.')
      vim.iter(errors):each(h.error)
      return
    end
    local warnings = json.get_warnings()
    if #warnings == 0 then
      h.ok('.vscode/settings.json loaded without errors.')
    else
      h.warn('.vscode/settings.json loaded with warnings.')
      vim.iter(warnings):each(h.warn)
    end
  end
end

function health.check()
  local types = require('rustaceanvim.types.internal')
  local config = require('rustaceanvim.config.internal')

  h.start('Checking for Lua dependencies')
  for _, dep in ipairs(lua_dependencies) do
    check_lua_dependency(dep)
  end

  h.start('Checking external dependencies')

  local adapter = types.evaluate(config.dap.adapter)
  ---@cast adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | boolean

  ---@return string
  local function get_rust_analyzer_binary()
    local default = 'rust-analyzer'
    if not config then
      return default
    end
    local cmd = types.evaluate(config.server.cmd)
    if not cmd or #cmd == 0 then
      return default
    end
    return cmd[1]
  end

  ---@type rustaceanvim.ExternalDependency[]
  local external_dependencies = {
    {
      name = 'rust-analyzer',
      get_binaries = function()
        return { get_rust_analyzer_binary() }
      end,
      is_installed = function(bin)
        if type(vim.system) == 'function' then
          local success = pcall(function()
            vim.system { bin, '--version' }
          end)
          return success
        end
        return vim.fn.executable(bin) == 1
      end,
      optional = function()
        return false
      end,
      url = '[rust-analyzer](https://rust-analyzer.github.io/)',
      info = 'Required by the LSP client.',
      extra_checks_if_not_installed = function()
        local bin = get_rust_analyzer_binary()
        if vim.fn.executable(bin) == 1 then
          h.warn("rust-analyzer wrapper detected. Run 'rustup component add rust-analyzer' to install rust-analyzer.")
        end
      end,
    },
    {
      name = 'Cargo',
      get_binaries = function()
        return { 'cargo' }
      end,
      optional = function()
        return true
      end,
      url = '[Cargo](https://doc.rust-lang.org/cargo/)',
      info = [[
      The Rust package manager.
      Required by rust-analyzer for non-standalone files, and for debugging features.
      Not required in standalone files.
    ]],
    },
    {
      name = 'rustc',
      get_binaries = function()
        return { 'rustc' }
      end,
      optional = function()
        return true
      end,
      url = '[rustc](https://doc.rust-lang.org/rustc/what-is-rustc.html)',
      info = [[
      The Rust compiler.
      Called by `:RustLsp explainError`.
    ]],
    },
  }

  if config.tools.cargo_override then
    table.insert(external_dependencies, {
      name = 'Cargo override: ' .. config.tools.cargo_override,
      get_binaries = function()
        return { config.tools.cargo_override }
      end,
      optional = function()
        return true
      end,
      url = '',
      info = [[
      Set in the config to override the 'cargo' command for debugging and testing.
    ]],
    })
  end

  if adapter ~= false then
    table.insert(external_dependencies, {
      name = adapter.name or 'debug adapter',
      get_binaries = function()
        if adapter.type == 'executable' then
          ---@cast adapter rustaceanvim.dap.executable.Config
          return { 'lldb', adapter.command }
        else
          ---@cast adapter rustaceanvim.dap.server.Config
          return { 'codelldb', adapter.executable.command }
        end
      end,
      optional = function()
        return true
      end,
      url = '[lldb](https://lldb.llvm.org/)',
      info = [[
      A debug adapter (defaults to: LLDB).
      Required for debugging features.
    ]],
    })
  end
  if adapter == false and is_dap_enabled() then
    h.warn('No debug adapter detected. Make sure either lldb or codelldb is available on the path.')
  end
  for _, dep in ipairs(external_dependencies) do
    check_external_dependency(dep)
  end
  check_config(config)
  check_for_conflicts()
  check_tree_sitter()
  check_json_config()
end

return health
