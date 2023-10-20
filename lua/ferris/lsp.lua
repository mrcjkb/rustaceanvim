local M = {}

local function override_apply_text_edits()
  local old_func = vim.lsp.util.apply_text_edits
  vim.lsp.util.apply_text_edits = function(edits, bufnr, offset_encoding)
    local overrides = require('ferris.overrides')
    overrides.snippet_text_edits_to_text_edits(edits)
    old_func(edits, bufnr, offset_encoding)
  end
end

local function is_library(fname)
  local cargo_home = os.getenv('CARGO_HOME') or vim.fs.joinpath(vim.env.HOME, '.cargo')
  local registry = vim.fs.joinpath(cargo_home, 'registry', 'src')

  local rustup_home = os.getenv('RUSTUP_HOME') or vim.fs.joinpath(vim.env.HOME, '.rustup')
  local toolchains = vim.fs.joinpath(rustup_home, 'toolchains')

  for _, item in ipairs { toolchains, registry } do
    if fname:sub(1, #item) == item then
      local clients = vim.lsp.get_clients { name = 'rust-analyzer' }
      return clients[#clients].config.root_dir
    end
  end
end

local function get_root_dir(fname)
  local reuse_active = is_library(fname)
  if reuse_active then
    return reuse_active
  end
  local cargo_crate_dir = vim.fs.dirname(vim.fs.find({ 'Cargo.toml' }, {
    upward = true,
    path = vim.fs.dirname(fname),
  })[1])
  local cmd = { 'cargo', 'metadata', '--no-deps', '--format-version', '1' }
  if cargo_crate_dir ~= nil then
    cmd[#cmd + 1] = '--manifest-path'
    cmd[#cmd + 1] = vim.fs.joinpath(cargo_crate_dir, 'Cargo.toml')
  end
  local cargo_metadata = ''
  local cm = vim.fn.jobstart(cmd, {
    on_stdout = function(_, d, _)
      cargo_metadata = table.concat(d, '\n')
    end,
    stdout_buffered = true,
  })
  if cm > 0 then
    cm = vim.fn.jobwait({ cm })[1]
  else
    cm = -1
  end
  local cargo_workspace_dir = nil
  if cm == 0 then
    cargo_workspace_dir = vim.fn.json_decode(cargo_metadata)['workspace_root']
  end
  return cargo_workspace_dir
    or cargo_crate_dir
    or vim.fs.dirname(vim.fs.find({ 'rust-project.json', '.git' }, {
      upward = true,
      path = vim.fs.dirname(fname),
    })[1])
end

-- Start or attach the LSP client
---@return integer|nil client_id The LSP client ID
M.start = function()
  local config = require('ferris.config.internal')
  local client_config = config.server
  local lsp_start_opts = vim.tbl_deep_extend('force', {}, client_config)
  local types = require('ferris.types.internal')
  lsp_start_opts.cmd = types.evaluate(client_config.cmd)
  lsp_start_opts.name = 'rust-analyzer'
  lsp_start_opts.filetypes = { 'rust' }
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- snippets
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  -- output highlights for all semantic tokens
  capabilities.textDocument.semanticTokens.augmentsSyntaxTokens = false

  -- send actions with hover request
  capabilities.experimental = {
    hoverActions = true,
    hoverRange = true,
    serverStatusNotification = true,
    snippetTextEdit = true,
    codeActionGroup = true,
    ssr = true,
  }

  -- enable auto-import
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }

  -- rust analyzer goodies
  capabilities.experimental.commands = {
    commands = {
      'rust-analyzer.runSingle',
      'rust-analyzer.debugSingle',
      'rust-analyzer.showReferences',
      'rust-analyzer.gotoLocation',
      'editor.action.triggerParameterHints',
    },
  }

  lsp_start_opts.capabilities = vim.tbl_deep_extend('force', capabilities, lsp_start_opts.capabilities or {})

  lsp_start_opts.root_dir = get_root_dir(vim.api.nvim_buf_get_name(0))

  local custom_handlers = {}
  custom_handlers['experimental/serverStatus'] = require('ferris.server_status').handler

  if config.tools.hover_actions.replace_builtin_hover then
    custom_handlers['textDocument/hover'] = require('ferris.hover_actions').handler
  end

  lsp_start_opts.handlers = vim.tbl_deep_extend('force', custom_handlers, lsp_start_opts.handlers or {})

  local lsp_commands = {
    RustCodeAction = {
      function()
        require('ferris.commands.code_action_group')()
      end,

      {},
    },
    RustViewCrateGraph = {
      function()
        require('ferris.commands.crate_graph')()
      end,
      {
        nargs = '*',
        complete = 'customlist,v:lua.rust_tools_get_graphviz_backends',
      },
    },
    RustDebuggables = {
      function()
        require('ferris.commands.debuggables')()
      end,
      {},
    },
    RustExpandMacro = {
      function()
        require('ferris.commands.expand_macro')()
      end,
      {},
    },
    RustOpenExternalDocs = {
      function()
        require('ferris.commands.external_docs')()
      end,
      {},
    },
    RustHoverActions = {
      function()
        require('ferris.hover_actions').hover_actions()
      end,
      {},
    },
    RustHoverRange = {
      function()
        require('ferris.commands.hover_range')()
      end,
      {},
    },
    RustLastDebug = {
      function()
        require('ferris.cached_commands').execute_last_debuggable()
      end,
      {},
    },
    RustLastRun = {
      function()
        require('ferris.cached_commands').execute_last_runnable()
      end,
      {},
    },
    RustJoinLines = {
      function()
        require('ferris.commands.join_lines')()
      end,
      {},
    },
    RustMoveItemDown = {
      function()
        require('ferris.commands.move_item')()
      end,
      {},
    },
    RustMoveItemUp = {
      function()
        require('ferris.commands.move_item')(true)
      end,
      {},
    },
    RustOpenCargo = {
      function()
        require('ferris.commands.open_cargo_toml')()
      end,
      {},
    },
    RustParentModule = {
      function()
        require('ferris.commands.parent_module')()
      end,
      {},
    },
    RustRunnables = {
      function()
        require('ferris.runnables').runnables()
      end,
      {},
    },
    RustSSR = {
      function(query)
        require('ferris.commands.ssr')(query)
      end,
      {
        nargs = '?',
      },
    },
    RustReloadWorkspace = {
      function()
        require('ferris.commands.workspace_refresh')()
      end,
      {},
    },
    RustSyntaxTree = {
      function()
        require('ferris.commands.syntax_tree')()
      end,
      {},
    },
    RustFlyCheck = {
      function()
        require('ferris.commands.fly_check')()
      end,
      {},
    },
  }

  local augroup = vim.api.nvim_create_augroup('FerrisAutoCmds', { clear = true })

  local old_on_init = lsp_start_opts.on_init
  lsp_start_opts.on_init = function(...)
    override_apply_text_edits()
    for name, command in pairs(lsp_commands) do
      vim.api.nvim_create_user_command(name, unpack(command))
    end
    if config.tools.reload_workspace_from_cargo_toml then
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = '*/Cargo.toml',
        callback = function()
          vim.cmd.RustReloadWorkspace()
        end,
        group = augroup,
      })
    end
    if type(old_on_init) == 'function' then
      old_on_init(...)
    end
  end

  local old_on_exit = lsp_start_opts.on_exit
  lsp_start_opts.on_exit = function(...)
    override_apply_text_edits()
    for name, _ in pairs(lsp_commands) do
      if vim.cmd[name] then
        vim.api.nvim_del_user_command(name)
      end
    end
    vim.api.nvim_del_augroup_by_id(augroup)
    if type(old_on_exit) == 'function' then
      old_on_exit(...)
    end
  end

  return vim.lsp.start(lsp_start_opts)
end

---@param bufnr number
---@return lsp.Client[]
local function get_active_ferris_clients(bufnr)
  return vim.lsp.get_clients { bufnr = bufnr, name = 'rust-analyzer' }
end

---Stop the LSP client.
---@return table[] clients A list of clients that will be stopped
M.stop = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = get_active_ferris_clients(bufnr)
  vim.lsp.stop_client(clients)
  return clients
end

local commands = {
  RustAnalyzerStart = {
    M.start,
    {},
  },
  RustAnalyzerStop = {
    M.stop,
    {},
  },
}

for name, command in pairs(commands) do
  vim.api.nvim_create_user_command(name, unpack(command))
end

return M
