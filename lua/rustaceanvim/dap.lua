local config = require('rustaceanvim.config.internal')
local compat = require('rustaceanvim.compat')
local shell = require('rustaceanvim.shell')
local types = require('rustaceanvim.types.internal')

local function scheduled_error(err)
  vim.schedule(function()
    vim.notify(err, vim.log.levels.ERROR)
  end)
end

local ok, _ = pcall(require, 'dap')
if not ok then
  return {
    ---@param _ RADebuggableArgs
    start = function(_)
      scheduled_error('nvim-dap not found.')
    end,
  }
end
local dap = require('dap')
local adapter = types.evaluate(config.dap.adapter)
--- @cast adapter DapExecutableConfig | DapServerConfig | boolean

if adapter ~= false then
  ---@TODO: Add nvim-dap to lua-ls lint
  ---@diagnostic disable-next-line: assign-type-mismatch
  dap.adapters.rt_lldb = adapter
end

local M = {}

---For the heroes who want to use it
---@param codelldb_path string
---@param liblldb_path string
---@return DapServerConfig
function M.get_codelldb_adapter(codelldb_path, liblldb_path)
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

local function get_cargo_args_from_runnables_args(runnable_args)
  local cargo_args = runnable_args.cargoArgs

  local message_json = '--message-format=json'
  if not compat.list_contains(cargo_args, message_json) then
    table.insert(cargo_args, message_json)
  end

  for _, value in ipairs(runnable_args.cargoExtraArgs) do
    if not compat.list_contains(cargo_args, value) then
      table.insert(cargo_args, value)
    end
  end

  return cargo_args
end

---@param callback fun(commit_hash:string)
local function get_rustc_commit_hash(callback)
  compat.system({ 'rustc', '--version', '--verbose' }, nil, function(sc)
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
  compat.system({ 'rustc', '--print', 'sysroot' }, nil, function(sc)
    ---@cast sc vim.SystemCompleted
    local result = sc.stdout
    if sc.code ~= 0 or result == nil then
      return
    end
    callback((result:gsub('\n$', '')))
  end)
end

---@alias DapSourceMap {[string]: string}

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

---@type DapSourceMap
local source_map = {}

---See https://github.com/vadimcn/codelldb/issues/204
local function generate_source_map()
  get_rustc_commit_hash(function(commit_hash)
    get_rustc_sysroot(function(rustc_sysroot)
      ---@type DapSourceMap
      local new_map = {
        [compat.joinpath('/rustc', commit_hash)] = compat.joinpath(rustc_sysroot, 'lib', 'rustlib', 'src', 'rust'),
      }
      source_map = vim.tbl_extend('force', source_map, new_map)
    end)
  end)
end

---@type {[string]: string}
local init_commands = {}

local function get_lldb_commands(workspace_root)
  get_rustc_sysroot(function(rustc_sysroot)
    local script_import = 'command script import "'
      .. compat.joinpath(rustc_sysroot, 'lib', 'rustlib', 'etc', 'lldb_lookup.py')
      .. '"'
    local commands_file = compat.joinpath(rustc_sysroot, 'lib', 'rustlib', 'etc', 'lldb_commands')
    local file = io.open(commands_file, 'r')
    local workspace_root_cmds = {}
    if file then
      for line in file:lines() do
        table.insert(workspace_root_cmds, line)
      end
      file:close()
    end
    table.insert(workspace_root_cmds, 1, script_import)
    init_commands = vim.tbl_extend('force', init_commands, { [workspace_root] = workspace_root_cmds })
  end)
end

---@type string[]
local environment = {}

-- Most succinct description: https://github.com/bevyengine/bevy/issues/2589#issuecomment-1753413600
---@param workspace_root string
local function add_dynamic_library_paths(workspace_root)
  compat.system({ 'rustc', '--print', 'target-libdir' }, nil, function(sc)
    ---@cast sc vim.SystemCompleted
    local result = sc.stdout
    if sc.code ~= 0 or result == nil then
      return
    end
    local rustc_target_path = (result:gsub('\n$', ''))
    local target_path = compat.joinpath(workspace_root, 'target', 'debug', 'deps')
    local sep = ':'
    local win_sep = ';'
    if shell.is_windows() then
      local path = os.getenv('PATH') or ''
      table.insert(environment, 'PATH=' .. rustc_target_path .. win_sep .. target_path .. win_sep .. path)
    elseif shell.is_macos() then
      local dkld_library_path = os.getenv('DKLD_LIBRARY_PATH') or ''
      table.insert(
        environment,
        'DKLD_LIBRARY_PATH=' .. rustc_target_path .. sep .. target_path .. sep .. dkld_library_path
      )
    else
      local ld_library_path = os.getenv('LD_LIBRARY_PATH') or ''
      table.insert(
        environment,
        'LD_LIBRARY_PATH=' .. rustc_target_path .. sep .. target_path .. sep .. ld_library_path
      )
    end
  end)
end

local function handle_configured_options(args)
  local is_generate_source_map_enabled = types.evaluate(config.dap.auto_generate_source_map)
  ---@cast is_generate_source_map_enabled boolean
  if is_generate_source_map_enabled then
    generate_source_map()
  end

  local is_load_rust_types_enabled = types.evaluate(config.dap.load_rust_types)
  ---@cast is_load_rust_types_enabled boolean
  if is_load_rust_types_enabled then
    get_lldb_commands(args.workspaceRoot)
  end

  local is_add_dynamic_library_paths_enabled = types.evaluate(config.dap.add_dynamic_library_paths)
  ---@cast is_add_dynamic_library_paths_enabled boolean
  if is_add_dynamic_library_paths_enabled then
    add_dynamic_library_paths(args.workspaceRoot)
  end
end

---@param args RADebuggableArgs
function M.start(args)
  vim.notify('Compiling a debug build for debugging. This might take some time...')
  handle_configured_options(args)

  local cargo_args = get_cargo_args_from_runnables_args(args)
  local cmd = vim.list_extend({ 'cargo' }, cargo_args)
  compat.system(cmd, { cwd = args.workspaceRoot }, function(sc)
    ---@cast sc vim.SystemCompleted
    local output = sc.stdout
    if sc.code ~= 0 or output == nil then
      scheduled_error(
        'An error occurred while compiling. Please fix all compilation issues and try again'
          .. (sc.stderr and ': ' .. sc.stderr or '.')
      )
      return
    end
    vim.schedule(function()
      local executables = {}
      for value in output:gmatch('([^\n]*)\n?') do
        local is_json, artifact = pcall(vim.fn.json_decode, value)
        if not is_json then
          goto loop_end
        end

        -- only process artifact if it's valid json object and it is a compiler artifact
        if type(artifact) ~= 'table' or artifact.reason ~= 'compiler-artifact' then
          goto loop_end
        end

        local is_binary = compat.list_contains(artifact.target.crate_types, 'bin')
        local is_build_script = compat.list_contains(artifact.target.kind, 'custom-build')
        local is_test = ((artifact.profile.test == true) and (artifact.executable ~= nil))
          or compat.list_contains(artifact.target.kind, 'test')
        -- only add executable to the list if we want a binary debug and it is a binary
        -- or if we want a test debug and it is a test
        if
          (cargo_args[1] == 'build' and is_binary and not is_build_script)
          or (cargo_args[1] == 'test' and is_test)
        then
          table.insert(executables, artifact.executable)
        end

        ::loop_end::
      end
      -- only 1 executable is allowed for debugging - error out if zero or many were found
      if #executables <= 0 then
        scheduled_error('No compilation artifacts found.')
        return
      end
      if #executables > 1 then
        scheduled_error('Multiple compilation artifacts are not supported.')
        return
      end

      -- create debug configuration
      local dap_config = {
        name = 'Rust tools debug',
        type = 'rt_lldb',
        request = 'launch',
        program = executables[1],
        args = args.executableArgs or {},
        cwd = args.workspaceRoot,
        stopOnEntry = false,

        -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
        --
        --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
        --
        -- Otherwise you might get the following error:
        --
        --    Error on launch: Failed to attach to the target process
        --
        -- But you should be aware of the implications:
        -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
        runInTerminal = false,
      }

      local final_config = next(init_commands) ~= nil
          and vim.tbl_deep_extend('force', dap_config, { initCommands = init_commands[args.workspaceRoot] })
        or dap_config

      final_config = next(source_map) ~= nil
          and vim.tbl_deep_extend('force', final_config, { sourceMap = tbl_to_tuple_list(source_map) })
        or final_config

      final_config = next(environment) ~= nil and vim.tbl_deep_extend('force', final_config, { env = environment })
        or final_config

      -- start debugging
      dap.run(final_config)
    end)
  end)
end

return M
