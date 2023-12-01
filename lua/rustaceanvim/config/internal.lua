local types = require('rustaceanvim.types.internal')
local compat = require('rustaceanvim.compat')
local config = require('rustaceanvim.config')

local RustaceanConfig

---@class RustAnalyzerInitializedStatusInternal : RustAnalyzerInitializedStatus
---@field health lsp_server_health_status
---@field quiescent boolean inactive?
---
---@param dap_adapter DapExecutableConfig | DapServerConfig | disable
---@return boolean
local function should_enable_dap_config_value(dap_adapter)
  local adapter = types.evaluate(dap_adapter)
  if adapter == false then
    return false
  end
  return vim.fn.executable('rustc') == 1
end

---@class RustaceanConfig
local RustaceanDefaultConfig = {
  ---@class RustaceanToolsConfig
  tools = {

    --- how to execute terminal commands
    --- options right now: termopen / quickfix / toggleterm / vimux
    ---@type RustaceanExecutor
    executor = require('rustaceanvim.executors').termopen,

    --- callback to execute once rust-analyzer is done initializing the workspace
    --- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
    ---@type fun(health:RustAnalyzerInitializedStatus) | nil
    on_initialized = nil,

    --- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    ---@type boolean
    reload_workspace_from_cargo_toml = true,

    --- options same as lsp hover
    ---@see vim.lsp.util.open_floating_preview
    ---@class RustaceanHoverActionsConfig
    hover_actions = {

      --- whether to replace Neovim's built-in `vim.lsp.buf.hover`
      ---@type boolean
      replace_builtin_hover = true,

      -- the border that is used for the hover window
      ---@see vim.api.nvim_open_win()
      ---@type string[][]
      border = {
        { '╭', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╮', 'FloatBorder' },
        { '│', 'FloatBorder' },
        { '╯', 'FloatBorder' },
        { '─', 'FloatBorder' },
        { '╰', 'FloatBorder' },
        { '│', 'FloatBorder' },
      },

      --- maximal width of the hover window. Nil means no max.
      ---@type integer | nil
      max_width = nil,

      --- maximal height of the hover window. Nil means no max.
      ---@type integer | nil
      max_height = nil,

      --- whether the hover action window gets automatically focused
      --- default: false
      ---@type boolean
      auto_focus = false,
    },

    --- settings for showing the crate graph based on graphviz and the dot
    --- command
    ---@class RustaceanCrateGraphConfig
    crate_graph = {
      -- backend used for displaying the graph
      -- see: https://graphviz.org/docs/outputs/
      -- default: x11
      ---@type string
      backend = 'x11',
      -- where to store the output, nil for no output stored (relative
      -- path from pwd)
      -- default: nil
      ---@type string | nil
      output = nil,
      -- true for all crates.io and external crates, false only the local
      -- crates
      -- default: true
      ---@type boolean
      full = true,

      -- List of backends found on: https://graphviz.org/docs/outputs/
      -- Is used for input validation and autocompletion
      -- Last updated: 2021-08-26
      ---@type string[]
      enabled_graphviz_backends = {
        'bmp',
        'cgimage',
        'canon',
        'dot',
        'gv',
        'xdot',
        'xdot1.2',
        'xdot1.4',
        'eps',
        'exr',
        'fig',
        'gd',
        'gd2',
        'gif',
        'gtk',
        'ico',
        'cmap',
        'ismap',
        'imap',
        'cmapx',
        'imap_np',
        'cmapx_np',
        'jpg',
        'jpeg',
        'jpe',
        'jp2',
        'json',
        'json0',
        'dot_json',
        'xdot_json',
        'pdf',
        'pic',
        'pct',
        'pict',
        'plain',
        'plain-ext',
        'png',
        'pov',
        'ps',
        'ps2',
        'psd',
        'sgi',
        'svg',
        'svgz',
        'tga',
        'tiff',
        'tif',
        'tk',
        'vml',
        'vmlz',
        'wbmp',
        'webp',
        'xlib',
        'x11',
      },
      ---@type string | nil
      pipe = nil,
    },

    ---@type fun(url:string):nil
    open_url = function(url)
      require('rustaceanvim.os').open_url(url)
    end,
  },

  --- all the opts to send to the LSP client
  --- these override the defaults set by rust-tools.nvim
  ---@class RustaceanLspClientConfig
  server = {
    ---@type boolean | fun():boolean Whether to automatically attach the LSP client.
    ---Defaults to `true` if the `rust-analyzer` executable is found.
    auto_attach = function()
      local cmd = types.evaluate(RustaceanConfig.server.cmd)
      ---@cast cmd string[]
      local rs_bin = cmd[1]
      return vim.fn.executable(rs_bin) == 1
    end,
    ---@type string[] | fun():string[]
    cmd = function()
      return { 'rust-analyzer', '--log-file', RustaceanConfig.server.logfile }
    end,
    --- standalone file support
    --- setting it to false may improve startup time
    ---@type boolean
    standalone = true,

    ---@type string The path to the rust-analyzer log file.
    logfile = vim.fn.tempname() .. '-rust-analyzer.log',

    ---@type table | (fun(project_root:string|nil):table) -- The rust-analyzer settings or a function that creates them.
    settings = function(project_root)
      return require('rustaceanvim.config.server').load_rust_analyzer_settings(project_root)
    end,

    --- @type table
    default_settings = {
      --- options to send to rust-analyzer
      --- See: https://rust-analyzer.github.io/manual.html#configuration
      --- @type table
      ['rust-analyzer'] = {},
    },
  },

  --- debugging stuff
  --- @class RustaceanDapConfig
  dap = {
    --- @type DapExecutableConfig | DapServerConfig | disable | fun():(DapExecutableConfig | DapServerConfig | disable)
    adapter = function()
      --- @type DapExecutableConfig | DapServerConfig | disable
      local result = false
      local has_mason, mason_registry = pcall(require, 'mason-registry')
      if has_mason and mason_registry.has_package('codelldb') then
        local codelldb_package = mason_registry.get_package('codelldb')
        local mason_codelldb_path = compat.joinpath(codelldb_package:get_install_path(), 'extension')
        local codelldb_path = compat.joinpath(mason_codelldb_path, 'adapter', 'codelldb')
        local liblldb_path = compat.joinpath(mason_codelldb_path, 'lldb', 'lib', 'liblldb')
        local shell = require('rustaceanvim.shell')
        if shell.is_windows() then
          codelldb_path = codelldb_path .. 'exe'
          liblldb_path = compat.joinpath(mason_codelldb_path, 'lldb', 'bin', 'liblldb.dll')
        else
          liblldb_path = liblldb_path .. (shell.is_macos() and '.dylib' or '.so')
        end
        result = config.get_codelldb_adapter(codelldb_path, liblldb_path)
      elseif vim.fn.executable('codelldb') == 1 then
        ---@cast result DapServerConfig
        result = {
          type = 'server',
          host = '127.0.0.1',
          port = '${port}',
          executable = {
            command = 'codelldb',
            args = { '--port', '${port}' },
          },
        }
      else
        local has_lldb_dap = vim.fn.executable('lldb-dap') == 1
        local has_lldb_vscode = vim.fn.executable('lldb-vscode') == 1
        if not has_lldb_dap and not has_lldb_vscode then
          return result
        end
        local command = has_lldb_dap and 'lldb-dap' or 'lldb-vscode'
        ---@cast result DapExecutableConfig
        result = {
          type = 'executable',
          command = command,
          name = 'lldb',
        }
      end
      return result
    end,
    --- Accommodate dynamically-linked targets by passing library paths to lldb.
    ---@type boolean | fun():boolean
    add_dynamic_library_paths = function()
      return should_enable_dap_config_value(RustaceanConfig.dap.adapter)
    end,
    --- Auto-generate a source map for the standard library.
    ---@type boolean | fun():boolean
    auto_generate_source_map = function()
      return should_enable_dap_config_value(RustaceanConfig.dap.adapter)
    end,
    --- Get Rust types via initCommands (rustlib/etc/lldb_commands).
    ---@type boolean | fun():boolean
    load_rust_types = function()
      return should_enable_dap_config_value(RustaceanConfig.dap.adapter)
    end,
  },
  was_g_rustaceanvim_sourced = vim.g.rustaceanvim ~= nil,
}

local rustaceanvim = vim.g.rustaceanvim or {}
local opts = type(rustaceanvim) == 'function' and rustaceanvim() or rustaceanvim
if opts.tools and opts.tools.executor and type(opts.tools.executor) == 'string' then
  opts.tools.executor = assert(require('rustaceanvim.executors')[opts.tools.executor], 'Unknown RustaceanExecutor')
end

---@type RustaceanConfig
RustaceanConfig = vim.tbl_deep_extend('force', {}, RustaceanDefaultConfig, opts)

-- Override user dap.adapter config in a backward compatible way
if opts.dap and opts.dap.adapter then
  local user_adapter = opts.dap.adapter
  local default_adapter = types.evaluate(RustaceanConfig.dap.adapter)
  if
    type(user_adapter) == 'table'
    and type(default_adapter) == 'table'
    and user_adapter.type == default_adapter.type
  then
    RustaceanConfig.dap.adapter = vim.tbl_deep_extend('force', default_adapter, user_adapter)
  elseif user_adapter ~= nil then
    RustaceanConfig.dap.adapter = user_adapter
  end
end

local check = require('rustaceanvim.config.check')
local ok, err = check.validate(RustaceanConfig)
if not ok then
  vim.notify('rustaceanvim: ' .. err, vim.log.levels.ERROR)
end

return RustaceanConfig
