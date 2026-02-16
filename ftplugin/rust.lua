if vim.fn.has('nvim-0.11') ~= 1 then
  vim.notify_once('rustaceanvim requires Neovim 0.11 or above', vim.log.levels.ERROR)
  return
end

---@type rustaceanvim.Config
local config = require('rustaceanvim.config.internal')

if not vim.g.loaded_rustaceanvim then
  require('rustaceanvim.config.check').check_for_lspconfig_conflict(vim.schedule_wrap(function(warn)
    vim.notify_once(warn, vim.log.levels.WARN)
  end))
  vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
    local runnables = require('rustaceanvim.runnables')
    local cached_commands = require('rustaceanvim.cached_commands')
    ---@type rustaceanvim.RARunnable[]
    local ra_runnables = command.arguments
    local runnable = ra_runnables[1]
    local cargo_args = runnable.args.cargoArgs
    if #cargo_args > 0 and vim.startswith(cargo_args[1], 'test') then
      cached_commands.set_last_testable(1, ra_runnables)
    end
    cached_commands.set_last_runnable(1, ra_runnables)
    runnables.run_command(1, ra_runnables)
  end

  vim.lsp.commands['rust-analyzer.gotoLocation'] = function(command, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if client then
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.lsp.util.show_document(command.arguments[1], client.offset_encoding or 'utf-8')
    end
  end

  vim.lsp.commands['rust-analyzer.showReferences'] = function(_)
    vim.lsp.buf.implementation()
  end

  vim.lsp.commands['rust-analyzer.debugSingle'] = function(command)
    local overrides = require('rustaceanvim.overrides')
    local args = command.arguments[1].args
    ---@diagnostic disable-next-line: undefined-field
    overrides.sanitize_command_for_debugging(args.cargoArgs)
    local cached_commands = require('rustaceanvim.cached_commands')
    cached_commands.set_last_debuggable(args)
    local rt_dap = require('rustaceanvim.dap')
    ---@diagnostic disable-next-line: invisible
    rt_dap.start(args)
  end

  local commands = require('rustaceanvim.commands')
  commands.create_rustc_command()
end

vim.g.loaded_rustaceanvim = true

local bufnr = vim.api.nvim_get_current_buf()

---@enum RustAnalyzerCmd
local RustAnalyzerCmd = {
  start = 'start',
  stop = 'stop',
  restart = 'restart',
  reload_settings = 'reloadSettings',
  target = 'target',
  config = 'config',
}

local function rust_analyzer_user_cmd(opts)
  local fargs = opts.fargs
  local cmd = table.remove(fargs, 1)
  local lsp = require('rustaceanvim.lsp')
  ---@cast cmd RustAnalyzerCmd
  if cmd == RustAnalyzerCmd.start then
    lsp.start(bufnr)
  elseif cmd == RustAnalyzerCmd.stop then
    lsp.stop(bufnr)
  elseif cmd == RustAnalyzerCmd.restart then
    lsp.restart(bufnr)
  elseif cmd == RustAnalyzerCmd.reload_settings then
    lsp.reload_settings(bufnr)
  elseif cmd == RustAnalyzerCmd.target then
    local target_arch = fargs[1]
    lsp.set_target_arch(bufnr, target_arch)
  elseif cmd == RustAnalyzerCmd.config then
    local ra_settings_str = vim.iter(fargs):join(' ')
    ---@diagnostic disable-next-line: param-type-mismatch
    local f = load('return ' .. ra_settings_str)
    ---@diagnostic disable-next-line: param-type-mismatch
    local ok, ra_settings = pcall(f)
    if not ok or type(ra_settings) ~= 'table' then
      return vim.notify('RustAnalyzer config: invalid Lua table.\n' .. ra_settings_str, vim.log.levels.ERROR)
    end
    lsp.set_config(bufnr, ra_settings)
  end
end

vim.api.nvim_buf_create_user_command(bufnr, 'RustAnalyzer', rust_analyzer_user_cmd, {
  nargs = '+',
  desc = 'Starts, stops the rust-analyzer LSP client or changes the target',
  complete = function(arg_lead, cmdline, _)
    local rust_analyzer = require('rustaceanvim.rust_analyzer')
    local clients = rust_analyzer.get_active_rustaceanvim_clients()
    ---@type RustAnalyzerCmd[]
    local commands = #clients == 0 and { 'start' } or { 'stop', 'restart', 'reloadSettings', 'target', 'config' }
    if cmdline:match('^RustAnalyzer%s+%w*$') then
      return vim.tbl_filter(function(command)
        return command:find(arg_lead) ~= nil
      end, commands)
    end
  end,
})

local auto_attach = config.server.auto_attach
if type(auto_attach) == 'function' then
  auto_attach = auto_attach(bufnr)
end

if auto_attach then
  require('rustaceanvim.lsp').start(bufnr)
end
