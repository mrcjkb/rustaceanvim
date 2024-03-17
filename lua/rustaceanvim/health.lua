---@mod rustaceanvim.health Health checks

local health = {}

local h = vim.health or require('health')
---@diagnostic disable-next-line: deprecated
local start = h.start or h.report_start
---@diagnostic disable-next-line: deprecated
local ok = h.ok or h.report_ok
---@diagnostic disable-next-line: deprecated
local error = h.error or h.report_error
---@diagnostic disable-next-line: deprecated
local warn = h.warn or h.report_warn

---@class LuaDependency
---@field module string The name of a module
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information

---@type LuaDependency[]
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

---@class ExternalDependency
---@field name string Name of the dependency
---@field get_binaries fun():string[] Function that returns the binaries to check for
---@field is_installed? fun(bin: string):boolean Default: `vim.fn.executable(bin) == 1`
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information
---@field extra_checks_if_installed? fun(bin: string) Optional extra checks to perform if the dependency is installed
---@field extra_checks_if_not_installed? fun() Optional extra checks to perform if the dependency is not installed

---@param dep LuaDependency
local function check_lua_dependency(dep)
  if pcall(require, dep.module) then
    ok(dep.url .. ' installed.')
    return
  end
  if dep.optional() then
    warn(('%s not installed. %s %s'):format(dep.module, dep.info, dep.url))
  else
    error(('Lua dependency %s not found: %s'):format(dep.module, dep.url))
  end
end

---@param dep ExternalDependency
---@return string|nil binary
---@return string|nil version
local check_installed = function(dep)
  local binaries = dep.get_binaries()
  for _, binary in ipairs(binaries) do
    local is_installed = dep.is_installed or function(bin)
      return vim.fn.executable(bin) == 1
    end
    if is_installed(binary) then
      local handle = io.popen(binary .. ' --version')
      if handle then
        local binary_version, error_msg = handle:read('*a')
        handle:close()
        if error_msg then
          return binary
        end
        return binary, binary_version
      end
      return binary
    end
  end
end

---@param dep ExternalDependency
local function check_external_dependency(dep)
  local binary, version = check_installed(dep)
  if binary then
    ---@cast binary string
    local mb_version_newline_idx = version and version:find('\n')
    local mb_version_len = version and (mb_version_newline_idx and mb_version_newline_idx - 1 or version:len())
    version = version and version:sub(0, mb_version_len) or '(unknown version)'
    ok(('%s: found %s'):format(dep.name, version))
    if dep.extra_checks_if_installed then
      dep.extra_checks_if_installed(binary)
    end
    return
  end
  if dep.optional() then
    warn(([[
      %s: not found.
      Install %s for extended capabilities.
      %s
      ]]):format(dep.name, dep.url, dep.info))
  else
    error(([[
      %s: not found.
      rustaceanvim requires %s.
      %s
      ]]):format(dep.name, dep.url, dep.info))
  end
  if dep.extra_checks_if_not_installed then
    dep.extra_checks_if_not_installed()
  end
end

---@param config RustaceanConfig
local function check_config(config)
  start('Checking config')
  if vim.g.rustaceanvim and not config.was_g_rustaceanvim_sourced then
    error('vim.g.rustaceanvim is set, but it was sourced after rustaceanvim was initialized.')
  end
  local valid, err = require('rustaceanvim.config.check').validate(config)
  if valid then
    ok('No errors found in config.')
  else
    error(err or '' .. vim.g.rustaceanvim and '' or ' This looks like a plugin bug!')
  end
end

local function check_for_conflicts()
  start('Checking for conflicting plugins')
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = 'FileType', pattern = 'rust' }) do
    if
      autocmd.group_name
      and autocmd.group_name == 'lspconfig'
      and autocmd.desc
      and autocmd.desc:match('rust_analyzer')
    then
      error(
        'lspconfig.rust_analyzer has been setup. This will likely lead to conflicts with the rustaceanvim LSP client.'
      )
      return
    end
  end
  if package.loaded['rustaceanvim.neotest'] ~= nil and package.loaded['neotest-rust'] ~= nil then
    error('rustaceanvim.neotest and neotest-rust are both loaded. This is likely a conflict.')
    return
  end
  ok('No conflicting plugins detected.')
end

local function check_tree_sitter()
  start('Checking for tree-sitter parser')
  local has_tree_sitter_rust_parser = #vim.api.nvim_get_runtime_file('parser/rust.so', true) > 0
  if has_tree_sitter_rust_parser then
    ok('tree-sitter parser for Rust detected.')
  else
    warn("No tree-sitter parser for Rust detected. Required by 'Rustc unpretty' command.")
  end
end

function health.check()
  local types = require('rustaceanvim.types.internal')
  local config = require('rustaceanvim.config.internal')

  start('Checking for Lua dependencies')
  for _, dep in ipairs(lua_dependencies) do
    check_lua_dependency(dep)
  end

  start('Checking external dependencies')

  local adapter = types.evaluate(config.dap.adapter)
  ---@cast adapter DapExecutableConfig | DapServerConfig | boolean

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

  ---@type ExternalDependency[]
  local external_dependencies = {
    {
      name = 'rust-analyzer',
      get_binaries = function()
        return { get_rust_analyzer_binary() }
      end,
      is_installed = function(bin)
        if vim.fn.has('nvim-0.10') then
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
          warn("rust-analyzer wrapper detected. Run 'rustup component add rust-analyzer' to install rust-analyzer.")
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

  if adapter ~= false then
    table.insert(external_dependencies, {
      name = adapter.name or 'debug adapter',
      get_binaries = function()
        if adapter.type == 'executable' then
          ---@cast adapter DapExecutableConfig
          return { 'lldb', adapter.command }
        else
          ---@cast adapter DapServerConfig
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
  for _, dep in ipairs(external_dependencies) do
    check_external_dependency(dep)
  end
  check_config(config)
  check_for_conflicts()
  check_tree_sitter()
end

return health
