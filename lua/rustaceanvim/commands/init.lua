---@mod rustaceanvim.commands

local config = require('rustaceanvim.config.internal')

---@class rustaceanvim.Commands
local M = {}

local rust_lsp_cmd_name = 'RustLsp'
local rustc_cmd_name = 'Rustc'

---@class rustaceanvim.command_tbl
---@field impl fun(args: string[], opts: vim.api.keyset.user_command) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] Command completions callback, taking the lead of the subcommand's arguments
---@field bang? boolean Whether this command supports a bang!

---@type rustaceanvim.command_tbl[]
local rustlsp_command_tbl = {
  codeAction = {
    impl = function(_)
      require('rustaceanvim.commands.code_action_group')()
    end,
  },
  crateGraph = {
    impl = function(args)
      require('rustaceanvim.commands.crate_graph')(unpack(args))
    end,
    complete = function(subcmd_arg_lead)
      return vim.tbl_filter(function(backend)
        return backend:find(subcmd_arg_lead) ~= nil
      end, config.tools.crate_graph.enabled_graphviz_backends or {})
    end,
  },
  debuggables = {
    ---@param args string[]
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      if opts.bang then
        require('rustaceanvim.cached_commands').execute_last_debuggable(args)
      else
        require('rustaceanvim.commands.debuggables').debuggables(args)
      end
    end,
    bang = true,
  },
  debug = {
    ---@param args string[]
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      if opts.bang then
        require('rustaceanvim.cached_commands').execute_last_debuggable(args)
      else
        require('rustaceanvim.commands.debuggables').debug(args)
      end
    end,
    bang = true,
  },
  expandMacro = {
    impl = function(_)
      require('rustaceanvim.commands.expand_macro')()
    end,
  },
  explainError = {
    impl = function(args)
      local subcmd = args[1] or 'cycle'
      if subcmd == 'cycle' then
        require('rustaceanvim.commands.diagnostic').explain_error()
      elseif subcmd == 'current' then
        require('rustaceanvim.commands.diagnostic').explain_error_current_line()
      else
        vim.notify(
          'explainError: unknown subcommand: ' .. subcmd .. " expected 'cycle' or 'current'",
          vim.log.levels.ERROR
        )
      end
    end,
    complete = function()
      return { 'cycle', 'current' }
    end,
  },
  relatedDiagnostics = {
    impl = function()
      require('rustaceanvim.commands.diagnostic').related_diagnostics()
    end,
  },
  renderDiagnostic = {
    impl = function(args)
      local subcmd = args[1] or 'cycle'
      if subcmd == 'cycle' then
        require('rustaceanvim.commands.diagnostic').render_diagnostic()
      elseif subcmd == 'current' then
        require('rustaceanvim.commands.diagnostic').render_diagnostic_current_line()
      else
        vim.notify(
          'renderDiagnostic: unknown subcommand: ' .. subcmd .. " expected 'cycle' or 'current'",
          vim.log.levels.ERROR
        )
      end
    end,
    complete = function()
      return { 'cycle', 'current' }
    end,
  },
  rebuildProcMacros = {
    impl = function()
      require('rustaceanvim.commands.rebuild_proc_macros')()
    end,
  },
  externalDocs = {
    impl = function(_)
      require('rustaceanvim.commands.external_docs')()
    end,
  },
  hover = {
    impl = function(args)
      if #args == 0 then
        vim.notify("hover: called without 'actions' or 'range'", vim.log.levels.ERROR)
        return
      end
      local subcmd = args[1]
      if subcmd == 'actions' then
        require('rustaceanvim.hover_actions').hover_actions()
      elseif subcmd == 'range' then
        require('rustaceanvim.commands.hover_range')()
      else
        vim.notify('hover: unknown subcommand: ' .. subcmd .. " expected 'actions' or 'range'", vim.log.levels.ERROR)
      end
    end,
    complete = function()
      return { 'actions', 'range' }
    end,
  },
  runnables = {
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      if opts.bang then
        require('rustaceanvim.cached_commands').execute_last_runnable(args)
      else
        require('rustaceanvim.runnables').runnables(args)
      end
    end,
    bang = true,
  },
  run = {
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      if opts.bang then
        require('rustaceanvim.cached_commands').execute_last_runnable(args)
      else
        require('rustaceanvim.runnables').run(args)
      end
    end,
    bang = true,
  },
  testables = {
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      if opts.bang then
        require('rustaceanvim.cached_commands').execute_last_testable()
      else
        require('rustaceanvim.runnables').runnables(args, { tests_only = true })
      end
    end,
    bang = true,
  },
  joinLines = {
    impl = function(_, opts)
      local cmds = require('rustaceanvim.commands.join_lines')
      ---@cast opts vim.api.keyset.user_command
      if opts.range and opts.range ~= 0 then
        cmds.join_lines_visual()
      else
        cmds.join_lines()
      end
    end,
  },
  moveItem = {
    impl = function(args)
      if #args == 0 then
        vim.notify("moveItem: called without 'up' or 'down'", vim.log.levels.ERROR)
        return
      end
      if args[1] == 'down' then
        require('rustaceanvim.commands.move_item')('Down')
      elseif args[1] == 'up' then
        require('rustaceanvim.commands.move_item')('Up')
      else
        vim.notify(
          'moveItem: unexpected argument: ' .. vim.inspect(args) .. " expected 'up' or 'down'",
          vim.log.levels.ERROR
        )
      end
    end,
    complete = function()
      return { 'up', 'down' }
    end,
  },
  openCargo = {
    impl = function(_)
      require('rustaceanvim.commands.open_cargo_toml')()
    end,
  },
  openDocs = {
    impl = function(_)
      require('rustaceanvim.commands.external_docs')()
    end,
  },
  parentModule = {
    impl = function(_)
      require('rustaceanvim.commands.parent_module')()
    end,
  },
  ssr = {
    impl = function(args, opts)
      ---@cast opts vim.api.keyset.user_command
      local query = args and #args > 0 and table.concat(args, ' ') or nil
      local cmds = require('rustaceanvim.commands.ssr')
      if opts.range and opts.range > 0 then
        cmds.ssr_visual(query)
      else
        cmds.ssr(query)
      end
    end,
  },
  reloadWorkspace = {
    impl = function()
      require('rustaceanvim.commands.workspace_refresh')()
    end,
  },
  workspaceSymbol = {
    ---@param opts vim.api.keyset.user_command
    impl = function(args, opts)
      local c = require('rustaceanvim.commands.workspace_symbol')
      ---@type WorkspaceSymbolSearchScope
      local searchScope = opts.bang and c.WorkspaceSymbolSearchScope.workspaceAndDependencies
        or c.WorkspaceSymbolSearchScope.workspace
      c.workspace_symbol(searchScope, args)
    end,
    complete = function(subcmd_arg_lead)
      local c = require('rustaceanvim.commands.workspace_symbol')
      return vim.tbl_filter(function(arg)
        return arg:find(subcmd_arg_lead) ~= nil
      end, vim.tbl_values(c.WorkspaceSymbolSearchKind))
      --
    end,
    bang = true,
  },
  syntaxTree = {
    impl = function()
      require('rustaceanvim.commands.syntax_tree')()
    end,
  },
  flyCheck = {
    impl = function(args)
      local cmd = args[1] or 'run'
      require('rustaceanvim.commands.fly_check')(cmd)
    end,
    complete = function(subcmd_arg_lead)
      return vim.tbl_filter(function(arg)
        return arg:find(subcmd_arg_lead) ~= nil
      end, { 'run', 'clear', 'cancel' })
    end,
  },
  view = {
    impl = function(args)
      if not args or #args == 0 then
        vim.notify("Expected argument: 'mir' or 'hir'", vim.log.levels.ERROR)
        return
      end
      local level
      local arg = args[1]:lower()
      if arg == 'mir' then
        level = 'Mir'
      elseif arg == 'hir' then
        level = 'Hir'
      else
        vim.notify('Unexpected argument: ' .. arg .. " Expected: 'mir' or 'hir'", vim.log.levels.ERROR)
        return
      end
      require('rustaceanvim.commands.view_ir')(level)
    end,
    complete = function(subcmd_arg_lead)
      return vim.tbl_filter(function(arg)
        return arg:find(subcmd_arg_lead) ~= nil
      end, { 'mir', 'hir' })
    end,
  },
  logFile = {
    impl = function()
      vim.cmd.e(config.server.logfile)
    end,
  },
}

---@type rustaceanvim.command_tbl[]
local rustc_command_tbl = {
  unpretty = {
    impl = function(args)
      local err_msg = table.concat(require('rustaceanvim.commands.rustc_unpretty').available_unpretty, ' | ')
      if not args or #args == 0 then
        vim.notify('Expected argument list: ' .. err_msg, vim.log.levels.ERROR)
        return
      end
      local arg = args[1]:lower()
      local available = false
      for _, value in ipairs(require('rustaceanvim.commands.rustc_unpretty').available_unpretty) do
        if value == arg then
          available = true
          break
        end
      end
      if not available then
        vim.notify('Expected argument list: ' .. err_msg, vim.log.levels.ERROR)
        return
      end
      require('rustaceanvim.commands.rustc_unpretty').rustc_unpretty(arg)
    end,
    complete = function(subcmd_arg_lead)
      return vim.tbl_filter(function(arg)
        return arg:find(subcmd_arg_lead) ~= nil
      end, require('rustaceanvim.commands.rustc_unpretty').available_unpretty)
    end,
  },
}

---@param command_tbl rustaceanvim.command_tbl
---@param opts table
---@see vim.api.nvim_create_user_command
local function run_command(command_tbl, cmd_name, opts)
  local fargs = opts.fargs
  local cmd = fargs[1]
  local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
  local command = command_tbl[cmd]
  if type(command) ~= 'table' or type(command.impl) ~= 'function' then
    vim.notify(cmd_name .. ': Unknown subcommand: ' .. cmd, vim.log.levels.ERROR)
    return
  end
  command.impl(args, opts)
end

---@param opts table
---@see vim.api.nvim_create_user_command
local function rust_lsp(opts)
  run_command(rustlsp_command_tbl, rust_lsp_cmd_name, opts)
end

---@param opts table
---@see vim.api.nvim_create_user_command
local function rustc(opts)
  run_command(rustc_command_tbl, rustc_cmd_name, opts)
end

---@generic K, V
---@param predicate fun(V):boolean
---@param tbl table<K, V>
---@return K[]
local function tbl_keys_by_value_filter(predicate, tbl)
  local ret = {}
  for k, v in pairs(tbl) do
    if predicate(v) then
      ret[k] = v
    end
  end
  return vim.tbl_keys(ret)
end

---Create the `:RustLsp` command
function M.create_rust_lsp_command()
  vim.api.nvim_create_user_command(rust_lsp_cmd_name, rust_lsp, {
    nargs = '+',
    range = true,
    bang = true,
    desc = 'Interacts with the rust-analyzer LSP client',
    complete = function(arg_lead, cmdline, _)
      local commands = cmdline:match("^['<,'>]*" .. rust_lsp_cmd_name .. '!') ~= nil
          -- bang!
          and tbl_keys_by_value_filter(function(command)
            return command.bang == true
          end, rustlsp_command_tbl)
        or vim.tbl_keys(rustlsp_command_tbl)
      local subcmd, subcmd_arg_lead = cmdline:match("^['<,'>]*" .. rust_lsp_cmd_name .. '[!]*%s(%S+)%s(.*)$')
      if subcmd and subcmd_arg_lead and rustlsp_command_tbl[subcmd] and rustlsp_command_tbl[subcmd].complete then
        return rustlsp_command_tbl[subcmd].complete(subcmd_arg_lead)
      end
      if cmdline:match("^['<,'>]*" .. rust_lsp_cmd_name .. '[!]*%s+%w*$') then
        return vim.tbl_filter(function(command)
          return command:find(arg_lead) ~= nil
        end, commands)
      end
    end,
  })
end

--- Delete the `:RustLsp` command
function M.delete_rust_lsp_command()
  if vim.cmd[rust_lsp_cmd_name] then
    pcall(vim.api.nvim_del_user_command, rust_lsp_cmd_name)
  end
end

---Create the `:Rustc` command
function M.create_rustc_command()
  vim.api.nvim_create_user_command(rustc_cmd_name, rustc, {
    nargs = '+',
    range = true,
    desc = 'Interacts with rustc',
    complete = function(arg_lead, cmdline, _)
      local commands = vim.tbl_keys(rustc_command_tbl)
      local subcmd, subcmd_arg_lead = cmdline:match('^' .. rustc_cmd_name .. '[!]*%s(%S+)%s(.*)$')
      if subcmd and subcmd_arg_lead and rustc_command_tbl[subcmd] and rustc_command_tbl[subcmd].complete then
        return rustc_command_tbl[subcmd].complete(subcmd_arg_lead)
      end
      if cmdline:match('^' .. rustc_cmd_name .. '[!]*%s+%w*$') then
        return vim.tbl_filter(function(command)
          return command:find(arg_lead) ~= nil
        end, commands)
      end
    end,
  })
end

return M
