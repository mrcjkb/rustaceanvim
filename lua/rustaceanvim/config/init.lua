---@mod rustaceanvim.config plugin configuration
---
---@brief [[
---
---rustaceanvim is a filetype plugin, and does not need
---a `setup` function to work.
---
---To configure rustaceanvim, set the variable `vim.g.rustaceanvim`,
---which is a `RustaceanOpts` table, in your neovim configuration.
---
---Example:
---
--->lua
------@type rustaceanvim.Opts
---vim.g.rustaceanvim = {
---   ---@type rustaceanvim.tools.Opts
---   tools = {
---     -- ...
---   },
---   ---@type rustaceanvim.lsp.ClientOpts
---   server = {
---     on_attach = function(client, bufnr)
---       -- Set keybindings, etc. here.
---     end,
---     default_settings = {
---       -- rust-analyzer language server configuration
---       ['rust-analyzer'] = {
---       },
---     },
---     -- ...
---   },
---   ---@type rustaceanvim.dap.Opts
---   dap = {
---     -- ...
---   },
--- }
---<
---
---Notes:
---
--- - `vim.g.rustaceanvim` can also be a function that returns a `rustaceanvim.Opts` table.
--- - `server.settings`, by default, is a function that looks for a `rust-analyzer.json` file
---    in the project root, to load settings from it. It falls back to an empty table.
---
---@brief ]]

local config = {}

---@type rustaceanvim.Opts | fun():rustaceanvim.Opts | nil
vim.g.rustaceanvim = vim.g.rustaceanvim

---@class rustaceanvim.Opts
---
---Plugin options.
---@field tools? rustaceanvim.tools.Opts
---
---Language server client options.
---In Neovim >= 0.11 (nightly), these can also be set using |vim.lsp.config()| for "rust-analyzer".
---If both the `server` table and a `vim.lsp.config["rust-analyzer"]` are defined,
---the |vim.lsp.config()| settings are merged into the `server` table, taking precedence over
---existing settings.
---@field server? rustaceanvim.lsp.ClientOpts
---
---Debug adapter options
---@field dap? rustaceanvim.dap.Opts

---@class rustaceanvim.tools.Opts
---
---The executor to use for runnables/debuggables
---@field executor? rustaceanvim.Executor | rustaceanvim.executor_alias
---
---The executor to use for runnables that are tests / testables
---@field test_executor? rustaceanvim.Executor | rustaceanvim.test_executor_alias
---
---The executor to use for runnables that are crate test suites (--all-targets)
---@field crate_test_executor? rustaceanvim.Executor | rustaceanvim.test_executor_alias
---
---Set this to override the 'cargo' command for runnables, debuggables (etc., e.g. to 'cross').
---If set, this takes precedence over 'enable_nextest'.
---@field cargo_override? string
---
---Whether to enable nextest. If enabled, `cargo test` commands will be transformed to `cargo nextest run` commands.
---Defaults to `true` if cargo-nextest is detected. Ignored if `cargo_override` is set.
---@field enable_nextest? boolean
---
---Whether to enable clippy checks on save if a clippy installation is detected.
---Default: `true`
---@field enable_clippy? boolean
---
---Function that is invoked when the LSP server has finished initializing
---@field on_initialized? fun(health:rustaceanvim.RAInitializedStatus, client_id:integer)
---
---Automatically call `RustReloadWorkspace` when writing to a Cargo.toml file
---@field reload_workspace_from_cargo_toml? boolean
---@field hover_actions? rustaceanvim.hover-actions.Opts Options for hover actions
---@field code_actions? rustaceanvim.code-action.Opts Options for code actions
---
---Options applied to floating windows.
---See |api-win_config|.
---@field float_win_config? rustaceanvim.FloatWinConfig
---
---Options for showing the crate graph based on graphviz and the dot
---@field create_graph? rustaceanvim.crate-graph.Opts
---
---If set, overrides how to open URLs
---@field open_url? fun(url:string):nil
---
---Options for `rustc`
---@field rustc? rustaceanvim.rustc.Opts

---@class rustaceanvim.Executor
---@field execute_command fun(cmd:string, args:string[], cwd:string|nil, opts?: rustaceanvim.ExecutorOpts)

---@class rustaceanvim.ExecutorOpts
---
---The buffer from which the executor was invoked.
---@field bufnr? integer

---@class rustaceanvim.FloatWinConfig
---@field auto_focus? boolean
---@field open_split? 'horizontal' | 'vertical'
---@see vim.lsp.util.open_floating_preview.Opts
---@see vim.api.nvim_open_win

---@alias rustaceanvim.executor_alias 'termopen' | 'quickfix' | 'toggleterm' | 'vimux'

---@alias rustaceanvim.test_executor_alias rustaceanvim.executor_alias | 'background' | 'neotest'

---@class rustaceanvim.hover-actions.Opts
---
---Whether to replace Neovim's built-in `vim.lsp.buf.hover` with hover actions.
---Default: `true`
---@field replace_builtin_hover? boolean

---@class rustaceanvim.code-action.Opts
---
---Text appended to a group action
---@field group_icon? string
---
---Whether to fall back to `vim.ui.select` if there are no grouped code actions.
---Default: `false`
---@field ui_select_fallback? boolean
---
---@field keys rustaceanvim.code-action.Keys

---@class rustaceanvim.code-action.Keys
---
---The key or keys with which to confirm a code action
---Default: `"<CR>"`.
---@field confirm? string | string[]
---
---The key or keys with which to close a code action window
---Default: `{ "q", "<Esc>" }`.
---@field quit? string

---@alias rustaceanvim.lsp_server_health_status 'ok' | 'warning' | 'error'

---@class rustaceanvim.RAInitializedStatus
---@field health rustaceanvim.lsp_server_health_status

---@class rustaceanvim.crate-graph.Opts
---
---Backend used for displaying the graph.
---See: https://graphviz.org/docs/outputs/
---Defaults to `"x11"` if unset.
---@field backend? string
---
---Where to store the output. No output if unset.
---Relative path from `cwd`.
---@field output? string
---
---Override the enabled graphviz backends list, used for input validation and autocompletion.
---@field enabled_graphviz_backends? string[]
---
---Override the pipe symbol in the shell command.
---Useful if using a shell that is not supported by this plugin.
---@field pipe? string

---@class rustaceanvim.rustc.Opts
---
---The default edition to use if it cannot be auto-detected.
---See https://rustc-dev-guide.rust-lang.org/guides/editions.html.
---Default '2021'.
---@field default_edition? string

---@class rustaceanvim.lsp.ClientOpts
---
---Whether to automatically attach the LSP client.
---Defaults to `true` if the `rust-analyzer` executable is found.
---@field auto_attach? boolean | fun(bufnr: integer):boolean
---
---Command and arguments for starting rust-analyzer
---Can be a list of arguments, a function that returns a list of arguments,
---or a function that returns an LSP RPC client factory (see |vim.lsp.rpc.connect|).
---@field cmd? string[] | fun():(string[]|fun(dispatchers: vim.lsp.rpc.Dispatchers): vim.lsp.rpc.PublicClient)
---
---The directory to use for the attached LSP.
---Can be a function, which may return nil if no server should attach.
---The second argument contains the default implementation, which can be used for fallback behavior.
---@field root_dir? string | fun(filename: string, default: fun(filename: string):string|nil):string|nil
---
---Options for connecting to ra-multiplex.
---@field ra_multiplex? rustaceanvim.ra_multiplex.Opts
---
---Setting passed to rust-analyzer.
---Defaults to a function that looks for a `rust-analyzer.json` file or returns an empty table.
---See https://rust-analyzer.github.io/manual.html#configuration.
---@field settings? table | fun(project_root:string|nil, default_settings: table):table
---
---Standalone file support (enabled by default).
---Disabling it may improve rust-analyzer's startup time.
---@field standalone? boolean
---
---The path to the rust-analyzer log file.
---@field logfile? string
---
---Whether to search (upward from the buffer) for rust-analyzer settings in .vscode/settings json.
---If found, loaded settings will override configured options.
---Default: `true`
---@field load_vscode_settings? boolean
---
---Server status warning level to notify at.
---Default: 'error'
---@field status_notify_level? rustaceanvim.server.status_notify_level
---
---@see vim.lsp.ClientConfig

---@class rustaceanvim.ra_multiplex.Opts
---
---Whether to enable ra-multiplex auto-discovery.
---Default: `true` if `server.cmd` is not set, otherwise `false`.
---If enabled, rustaceanvim will try to detect if an ra-multiplex server is running
---and connect to it (Linux and MacOS only).
---If auto-discovery does not work, you can set `server.cmd` to a function that
---returns an LSP RPC client factory (see |vim.lsp.rpc.connect|).
---@field enable? boolean
---
---The host to connect to. Default: '127.0.0.1'
---@field host? string
---
---The port to connect to. Default: 27631
---@field port? integer

---@alias rustaceanvim.server.status_notify_level 'error' | 'warning' | rustaceanvim.disable

---@alias rustaceanvim.disable false

---@class rustaceanvim.dap.Opts
---
---Whether to autoload nvim-dap configurations when rust-analyzer has attached?
---Default: `true`
---@field autoload_configurations? boolean
---
---Defaults to creating the `rt_lldb` adapter, which is a |rustaceanvim.dap.server.Config|
---if `codelldb` is detected, and a |rustaceanvim.dap.executable.Config|` if `lldb` is detected.
---Set to `false` to disable.
---@field adapter? rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable)
---
---Dap client configuration. Defaults to a function that looks for a `launch.json` file
---or returns a |rustaceanvim.dap.executable.Config| that launches the `rt_lldb` adapter.
---Set to `false` to disable.
---@field configuration? rustaceanvim.dap.client.Config | rustaceanvim.disable | fun():(rustaceanvim.dap.client.Config | rustaceanvim.disable)
---
---Accommodate dynamically-linked targets by passing library paths to lldb.
---Default: `true`.
---@field add_dynamic_library_paths? boolean | fun():boolean
---
---Whether to auto-generate a source map for the standard library.
---@field auto_generate_source_map? fun():boolean | boolean
---
---Whether to get Rust types via initCommands (rustlib/etc/lldb_commands, lldb only).
---Default: `true`.
---@field load_rust_types? fun():boolean | boolean

---@alias rustaceanvim.dap.Command string

---@class rustaceanvim.dap.executable.Config
---
---The type of debug adapter.
---@field type rustaceanvim.dap.adapter.types.executable
---@field command string Default: `"lldb-vscode"`.
---@field args? string Default: unset.
---@field name? string Default: `"lldb"`.

---@class rustaceanvim.dap.server.Config
---@field type rustaceanvim.dap.adapter.types.server The type of debug adapter.
---@field host? string The host to connect to.
---@field port string The port to connect to.
---@field executable rustaceanvim.dap.Executable The executable to run
---@field name? string

---@class rustaceanvim.dap.Executable
---@field command string The executable.
---@field args string[] Its arguments.

---@alias rustaceanvim.dap.adapter.types.executable "executable"
---@alias rustaceanvim.dap.adapter.types.server "server"

---@class rustaceanvim.dap.client.Config: dap.Configuration
---@field type string The dap adapter to use
---@field name string
---@field request rustaceanvim.dap.config.requests.launch | rustaceanvim.dap.config.requests.attach | rustaceanvim.dap.config.requests.custom The type of dap session
---@field cwd? string Current working directory
---@field program? string Path to executable for most DAP clients
---@field args? string[] Optional args to DAP client, not valid for all client types
---@field env? rustaceanvim.EnvironmentMap Environmental variables
---@field initCommands? string[] Initial commands to run, `lldb` clients only
---
---Essential config values for `probe-rs` client, see https://probe.rs/docs/tools/debugger/
---@field coreConfigs? table

---@alias rustaceanvim.EnvironmentMap table<string, string[]>

---@alias rustaceanvim.dap.config.requests.launch "launch"
---@alias rustaceanvim.dap.config.requests.attach "attach"
---@alias rustaceanvim.dap.config.requests.custom "custom"

---For the heroes who want to use it.
---@param codelldb_path string Path to the codelldb executable
---@param liblldb_path string Path to the liblldb dynamic library
---@return rustaceanvim.dap.server.Config
function config.get_codelldb_adapter(codelldb_path, liblldb_path)
  return {
    type = 'server',
    port = '${port}',
    host = '127.0.0.1',
    executable = {
      command = codelldb_path,
      args = { '--liblldb', liblldb_path, '--port', '${port}' },
    },
  }
end

return config
