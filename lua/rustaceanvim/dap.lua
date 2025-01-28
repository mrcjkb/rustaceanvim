---@mod rustaceanvim.dap
---@brief [[
---
--- The DAP integration requires `nvim-dap` https://github.com/mfussenegger/nvim-dap
--- (Please read the plugin's documentation, see |dap-adapter|)
--- and a debug adapter (e.g. `lldb` https://lldb.llvm.org/
--- or `codelldb` https://github.com/vadimcn/codelldb).
---
--- By default, this plugin will silently attempt to autoload |dap-configuration|s
--- when the LSP client attaches.
--- You can call them with `require('dap').continue()` or `:DapContinue` once
--- they have been loaded. The feature can be disabled by setting
--- `vim.g.rustaceanvim.dap.autoload_configurations = false`.
---
--- - `:RustLsp debuggables` will only load debug configurations
---   created by `rust-analyzer`.
--- - `require('dap').continue()` will load all Rust debug configurations,
---   including those specified in a `.vscode/launch.json`
---   (see |dap-launch.json|)
---
--- IMPORTANT: Note that rustaceanvim may only be able to load DAP configurations
--- when rust-analyzer has finished initializing (which may be after
--- the client attaches, in large projects). This means that the
--- DAP configurations may not be loaded immediately upon startup.
---
---@brief ]]

local config = require('rustaceanvim.config.internal')
local shell = require('rustaceanvim.shell')
local types = require('rustaceanvim.types.internal')

---@param err string
local function scheduled_error(err)
  vim.schedule(function()
    vim.notify(err, vim.log.levels.ERROR)
  end)
end

local ok, _ = pcall(require, 'dap')
if not ok then
  return {
    ---@param on_error fun(err:string)
    start = function(_, _, _, on_error)
      on_error = on_error or scheduled_error
      on_error('nvim-dap not found.')
    end,
  }
end
local dap = require('dap')

local M = {}

local function get_cargo_args_from_runnables_args(runnable_args)
  local cargo_args = runnable_args.cargoArgs

  local message_json = '--message-format=json'
  if not vim.list_contains(cargo_args, message_json) then
    table.insert(cargo_args, message_json)
  end

  for _, value in ipairs(runnable_args.cargoExtraArgs or {}) do
    if not vim.list_contains(cargo_args, value) then
      table.insert(cargo_args, value)
    end
  end

  return cargo_args
end

---@param callback fun(commit_hash:string)
local function get_rustc_commit_hash(callback)
  vim.system({ 'rustc', '--version', '--verbose' }, nil, function(sc)
    ---@cast sc vim.SystemCompleted
    local result = sc.stdout
    if sc.code ~= 0 or result == nil then
      return
    end
    local commit_hash = result:match('commit%-hash:%s+([^\n]+)')
    if not commit_hash then
      return
    end
    callback(commit_hash)
  end)
end

local function get_rustc_sysroot(callback)
  vim.system({ 'rustc', '--print', 'sysroot' }, nil, function(sc)
    ---@cast sc vim.SystemCompleted
    local result = sc.stdout
    if sc.code ~= 0 or result == nil then
      return
    end
    callback((result:gsub('\n$', '')))
  end)
end

---@package
---@alias rustaceanvim.dap.SourceMap {[string]: string}

---@param tbl { [string]: string }
---@return string[][]
local function tbl_to_tuple_list(tbl)
  ---@type string[][]
  local result = {}
  for k, v in pairs(tbl) do
    ---@type string[]
    local tuple = { k, v }
    table.insert(result, tuple)
  end
  return result
end

---codelldb expects a map,
-- while lldb expects a list of tuples.
---@param adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | boolean
---@param tbl { [string]: string }
---@return string[][] | { [string]: string }
local function format_source_map(adapter, tbl)
  if adapter.type == 'server' then
    return tbl
  end
  return tbl_to_tuple_list(tbl)
end

---@type {[string]: rustaceanvim.dap.SourceMap}
local source_maps = {}

---See https://github.com/vadimcn/codelldb/issues/204
---@param workspace_root? string
local function generate_source_map(workspace_root)
  if not workspace_root or source_maps[workspace_root] then
    return
  end
  get_rustc_commit_hash(function(commit_hash)
    get_rustc_sysroot(function(rustc_sysroot)
      local src_path
      for _, src_dir in pairs { 'src', 'rustc-src' } do
        src_path = vim.fs.joinpath(rustc_sysroot, 'lib', 'rustlib', src_dir, 'rust')
        if vim.uv.fs_stat(src_path) then
          break
        end
        src_path = nil
      end
      if not src_path then
        return
      end
      ---@type rustaceanvim.dap.SourceMap
      source_maps[workspace_root] = {
        [vim.fs.joinpath('/rustc', commit_hash)] = src_path,
      }
    end)
  end)
end

---@type {[string]: string[]}
local init_commands = {}

---@param workspace_root? string
local function get_lldb_commands(workspace_root)
  if not workspace_root or init_commands[workspace_root] then
    return
  end
  get_rustc_sysroot(function(rustc_sysroot)
    local script = vim.fs.joinpath(rustc_sysroot, 'lib', 'rustlib', 'etc', 'lldb_lookup.py')
    if not vim.uv.fs_stat(script) then
      return
    end
    local script_import = 'command script import "' .. script .. '"'
    local commands_file = vim.fs.joinpath(rustc_sysroot, 'lib', 'rustlib', 'etc', 'lldb_commands')
    local file = io.open(commands_file, 'r')
    local workspace_root_cmds = {}
    if file then
      for line in file:lines() do
        table.insert(workspace_root_cmds, line)
      end
      file:close()
    end
    table.insert(workspace_root_cmds, 1, script_import)
    init_commands[workspace_root] = workspace_root_cmds
  end)
end

---map for codelldb, list of strings for lldb-dap
---@param adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config
---@param key string
---@param segments string[]
---@param sep string
---@return {[string]: string} | string[]
local function format_environment_variable(adapter, key, segments, sep)
  ---@diagnostic disable-next-line: missing-parameter
  local existing = vim.uv.os_getenv(key)
  existing = existing and sep .. existing or ''
  local value = table.concat(segments, sep) .. existing
  return adapter.type == 'server' and { [key] = value } or { key .. '=' .. value }
end

---@type {[string]: rustaceanvim.EnvironmentMap}
local environments = {}

-- Most succinct description: https://github.com/bevyengine/bevy/issues/2589#issuecomment-1753413600
---@param adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config
---@param workspace_root string | nil
local function add_dynamic_library_paths(adapter, workspace_root)
  if not workspace_root or environments[workspace_root] then
    return
  end
  vim.system({ 'rustc', '--print', 'target-libdir' }, { cwd = workspace_root }, function(sc)
    ---@cast sc vim.SystemCompleted
    local result = sc.stdout
    if sc.code ~= 0 or result == nil then
      return
    end
    local rustc_target_path = (result:gsub('\n$', ''))
    local target_path = vim.fs.joinpath(workspace_root, 'target', 'debug', 'deps')
    if shell.is_windows() then
      environments[workspace_root] = environments[workspace_root]
        or format_environment_variable(adapter, 'PATH', { rustc_target_path, target_path }, ';')
    elseif shell.is_macos() then
      ---@diagnostic disable-next-line: missing-parameter
      environments[workspace_root] = environments[workspace_root]
        or format_environment_variable(adapter, 'DYLD_LIBRARY_PATH', { rustc_target_path, target_path }, ':')
    else
      ---@diagnostic disable-next-line: missing-parameter
      environments[workspace_root] = environments[workspace_root]
        or format_environment_variable(adapter, 'LD_LIBRARY_PATH', { rustc_target_path, target_path }, ':')
    end
  end)
end

---@param action fun() Action to perform
---@param desc? string Description of the action or nil to suppress warning
local function pall_with_warn(action, desc)
  local success, err = pcall(action)
  if not success and desc then
    vim.schedule(function()
      vim.notify(desc .. ' failed: ' .. err, vim.log.levels.WARN)
    end)
  end
end

---@param adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config
---@param args rustaceanvim.RARunnableArgs
---@param verbose? boolean
local function handle_configured_options(adapter, args, verbose)
  local is_generate_source_map_enabled = types.evaluate(config.dap.auto_generate_source_map)
  ---@cast is_generate_source_map_enabled boolean
  if is_generate_source_map_enabled then
    pall_with_warn(function()
      generate_source_map(args.workspaceRoot)
    end, verbose and 'Generating source map' or nil)
  end

  local is_load_rust_types_enabled = types.evaluate(config.dap.load_rust_types)
  ---@cast is_load_rust_types_enabled boolean
  if is_load_rust_types_enabled then
    pall_with_warn(function()
      get_lldb_commands(args.workspaceRoot)
    end, verbose and 'Getting LLDB commands' or nil)
  end

  local is_add_dynamic_library_paths_enabled = types.evaluate(config.dap.add_dynamic_library_paths)
  ---@cast is_add_dynamic_library_paths_enabled boolean
  if is_add_dynamic_library_paths_enabled then
    pall_with_warn(function()
      add_dynamic_library_paths(adapter, args.workspaceRoot)
    end, verbose and 'Adding library paths' or nil)
  end
end

---@package
---@param args rustaceanvim.RARunnableArgs
---@param verbose? boolean
---@param callback? fun(config: rustaceanvim.dap.client.Config)
---@param on_error? fun(err: string)
function M.start(args, verbose, callback, on_error)
  if verbose then
    on_error = on_error or scheduled_error
  else
    on_error = on_error or function() end
  end
  if type(callback) ~= 'function' then
    callback = dap.run
  end
  local adapter = types.evaluate(config.dap.adapter)
  --- @cast adapter rustaceanvim.dap.executable.Config | rustaceanvim.dap.server.Config | rustaceanvim.disable
  if adapter == false then
    on_error('Debug adapter is disabled.')
    return
  end

  handle_configured_options(adapter, args, verbose)

  local cargo_args = get_cargo_args_from_runnables_args(args)
  local cmd = vim.list_extend({ config.tools.cargo_override or 'cargo' }, cargo_args)
  if verbose then
    vim.notify('Compiling a debug build for debugging. This might take some time...')
  end
  vim.system(cmd, { cwd = args.workspaceRoot }, function(sc)
    ---@cast sc vim.SystemCompleted
    local output = sc.stdout
    if sc.code ~= 0 or output == nil then
      on_error(
        'An error occurred while compiling. Please fix all compilation issues and try again.'
          .. '\nCommand: '
          .. table.concat(cmd, ' ')
          .. (sc.stderr and '\nstderr: \n' .. sc.stderr or '')
          .. (output and '\nstdout: ' .. output or '')
      )
      return
    end
    vim.schedule(function()
      local executables = {}
      vim
        .iter(output:gmatch('([^\n]*)\n?'))
        ---@param value string
        :map(function(value)
          local is_json, artifact = pcall(vim.fn.json_decode, value)
          ---@diagnostic disable-next-line: redundant-return-value
          return is_json, artifact
        end)
        ---@param is_json boolean
        :filter(function(is_json, artifact)
          -- only process artifact if it's valid json object and it is a compiler artifact
          return is_json and type(artifact) == 'table' and artifact.reason == 'compiler-artifact'
        end)
        ---@param artifact table
        :each(function(_, artifact)
          local is_binary = vim.list_contains(artifact.target.crate_types, 'bin')
          local is_build_script = vim.list_contains(artifact.target.kind, 'custom-build')
          local is_test = ((artifact.profile.test == true) and (artifact.executable ~= nil))
            or vim.list_contains(artifact.target.kind, 'test')
          -- only add executable to the list if we want a binary debug and it is a binary
          -- or if we want a test debug and it is a test
          if
            (cargo_args[1] == 'build' and is_binary and not is_build_script)
            or (cargo_args[1] == 'test' and is_test)
          then
            table.insert(executables, artifact.executable)
          end
        end)
      -- only 1 executable is allowed for debugging - error out if zero or many were found
      if #executables <= 0 then
        on_error('No compilation artifacts found.')
        return
      end
      if #executables > 1 then
        on_error('Multiple compilation artifacts are not supported.')
        return
      end

      -- If the adapter is not defined elsewhere, use the adapter
      -- defined in `config.dap.adapter`
      local is_codelldb = adapter.type == 'server'
      local adapter_key = is_codelldb and 'codelldb' or 'lldb'
      if dap.adapters[adapter_key] == nil then
        ---@TODO: Add nvim-dap to lua-ls lint
        ---@diagnostic disable-next-line: assign-type-mismatch
        dap.adapters[adapter_key] = adapter
      end

      -- Use the first configuration, if it exists
      local _, dap_config = next(dap.configurations.rust or {})

      local local_config = types.evaluate(config.dap.configuration)
      --- @cast local_config rustaceanvim.dap.client.Config | boolean

      ---@diagnostic disable-next-line: param-type-mismatch
      local final_config = local_config ~= false and vim.deepcopy(local_config) or vim.deepcopy(dap_config)
      --- @cast final_config rustaceanvim.dap.client.Config

      local err
      ok, err = pcall(vim.validate, {
        type = { final_config.type, 'string' },
        name = { final_config.name, 'string' },
        request = { final_config.request, 'string' },
      })
      if not ok then
        on_error(([[
DAP client config validation failed.
%s
If you have specified a custom configuration, see ":h rustaceanvim.dap.client.Config".
]]):format(err))
        return
      end
      if dap.adapters[final_config.type] == nil then
        on_error('No adapter exists named "' .. final_config.type .. '". See ":h dap-adapter" for more information')
        return
      end

      -- common entries
      -- `program` and `args` aren't supported in probe-rs but are safely ignored
      final_config.cwd = args.workspaceRoot
      final_config.program = executables[1]
      final_config.args = args.executableArgs or {}
      local environment = args.workspaceRoot and environments[args.workspaceRoot]
      final_config = next(environment or {}) ~= nil
          and vim.tbl_deep_extend('force', final_config, { env = environment })
        or final_config

      if string.find(final_config.type, 'lldb') ~= nil then
        -- lldb specific entries
        final_config = args.workspaceRoot
            and next(init_commands or {}) ~= nil
            and vim.tbl_deep_extend('force', final_config, { initCommands = init_commands[args.workspaceRoot] })
          or final_config

        local source_map = args.workspaceRoot and source_maps[args.workspaceRoot]
        final_config = source_map
            and next(source_map or {}) ~= nil
            and vim.tbl_deep_extend('force', final_config, { sourceMap = format_source_map(adapter, source_map) })
          or final_config
      elseif string.find(final_config.type, 'probe%-rs') ~= nil then
        -- probe-rs specific entries
        final_config.coreConfigs[1].programBinary = final_config.program
      end

      -- start debugging
      callback(final_config)
    end)
  end)
end

return M
