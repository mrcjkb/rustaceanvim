---@mod rustaceanvim.health Health checks

local health = {}

local Types = require('rustaceanvim.types.internal')
---@type RustaceanConfig
local config = require('rustaceanvim.config.internal')
local h = vim.health or require('health')
local start = h.start or h.report_start
local ok = h.ok or h.report_ok
local error = h.error or h.report_error
local warn = h.warn or h.report_warn

---@class LuaDependency
---@field module string The name of a module
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information

---@type LuaDependency[]
local lua_dependencies = {
  {
    module = 'plenary',
    optional = function()
      return true
    end,
    url = '[nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim)',
    info = 'Needed for debugging features.',
  },
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
---@field get_binaries fun():string[]Function that returns the binaries to check for
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information
---@field extra_checks function|nil Optional extra checks to perform if the dependency is installed

---@type ExternalDependency[]
local external_dependencies = {
  {
    name = 'rust-analyzer',
    get_binaries = function()
      local default = { 'rust-analyzer' }
      if not config then
        return default
      end
      local cmd = Types.evaluate(config.server.cmd)
      if not cmd or #cmd == 0 then
        return default
      end
      return { cmd[1] }
    end,
    optional = function()
      return false
    end,
    url = '[rust-analyzer](https://rust-analyzer.github.io/)',
    info = 'Required by the LSP client.',
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
  {
    name = config.dap.adapter.command,
    get_binaries = function()
      return { config.dap.adapter.command }
    end,
    optional = function()
      return true
    end,
    url = '[lldb](https://lldb.llvm.org/)',
    info = [[
      A debug adapter (defaultst to: LLDB).
      Required for debugging features.
    ]],
  },
}

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
---@return boolean is_installed
---@return string|nil version
local check_installed = function(dep)
  local binaries = dep.get_binaries()
  for _, binary in ipairs(binaries) do
    if vim.fn.executable(binary) == 1 then
      local handle = io.popen(binary .. ' --version')
      if handle then
        local binary_version, error_msg = handle:read('*a')
        handle:close()
        if error_msg then
          return true
        end
        return true, binary_version
      end
      return true
    end
  end
  return false
end

---@param dep ExternalDependency
local function check_external_dependency(dep)
  local installed, mb_version = check_installed(dep)
  if installed then
    local mb_version_newline_idx = mb_version and mb_version:find('\n')
    local mb_version_len = mb_version and (mb_version_newline_idx and mb_version_newline_idx - 1 or mb_version:len())
    local version = mb_version and mb_version:sub(0, mb_version_len) or '(unknown version)'
    ok(('%s: found %s'):format(dep.name, version))
    if dep.extra_checks then
      dep.extra_checks()
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
end

local function check_config()
  start('Checking config')
  if vim.g.rustaceanvim then
    ok('vim.g.rustaceanvim is set')
  else
    ok('vim.g.rustaceanvim is not set')
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
    if autocmd.group_name and autocmd.group_name == 'lspconfig' then
      error(
        'lspconfig.rust_analyzer has been setup. This will likely lead to conflicts with the rustaceanvim LSP client.'
      )
      return
    end
  end
  ok('No conflicting plugins detected.')
end

function health.check()
  start('Checking for Lua dependencies')
  for _, dep in ipairs(lua_dependencies) do
    check_lua_dependency(dep)
  end

  start('Checking external dependencies')
  for _, dep in ipairs(external_dependencies) do
    check_external_dependency(dep)
  end
  check_config()
  check_for_conflicts()
end

return health
