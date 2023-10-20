local vim = vim

---@type FerrisConfig
local FerrisConfig = {}

-- Needed for autocompletion to work
_G.rust_tools_get_graphviz_backends = function()
  return FerrisConfig.tools.crate_graph.enabled_graphviz_backends
end

---@class FerrisConfig
local FerrisDefaultConfig = {
  ---@class FerrisToolsConfig
  tools = {

    --- how to execute terminal commands
    --- options right now: termopen / quickfix / toggleterm / vimux
    ---@type FerrisExecutor
    executor = require('ferris.executors').termopen,

    --- callback to execute once rust-analyzer is done initializing the workspace
    --- The callback receives one parameter indicating the `health` of the server: "ok" | "warning" | "error"
    ---@type fun(health:lsp_server_health_status) | nil
    on_initialized = nil,

    --- automatically call RustReloadWorkspace when writing to a Cargo.toml file.
    ---@type boolean
    reload_workspace_from_cargo_toml = true,

    --- options same as lsp hover
    ---@see vim.lsp.util.open_floating_preview
    ---@class FerrisHoverActionsConfig
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
    ---@class FerrisCrateGraphConfig
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
  },

  --- all the opts to send to the LSP client
  --- these override the defaults set by rust-tools.nvim
  ---class FerrisLspClientConfig
  server = {
    ---@type string[] | fun():string[]
    cmd = function()
      return { 'rust-analyzer' }
    end,
    --- standalone file support
    --- setting it to false may improve startup time
    ---@type boolean
    standalone = true,

    --- options to send to rust-analyzer
    --- See: https://rust-analyzer.github.io/manual.html#configuration
    --- @type table
    ['rust-analyzer'] = {},
  },

  --- debugging stuff
  --- @class FerrisDapConfig
  dap = {
    --- @class FerrisDapAdapterConfig
    adapter = {
      ---@type string
      type = 'executable',
      ---@type string
      command = 'lldb-vscode',
      ---@type string
      name = 'ferris_lldb',
    },
  },
}

local ferris = vim.g.ferris or {}
local opts = type(ferris) == 'function' and ferris() or ferris
if opts.tools and opts.tools.executor and type(opts.tools.executor) == 'string' then
  opts.tools.executor = assert(require('ferris.executors')[opts.tools.executor], 'Unknown FerrisExecutor')
end
FerrisConfig = vim.tbl_deep_extend('force', {}, FerrisDefaultConfig, opts)

return FerrisConfig
