local config = require('rustaceanvim.config.internal')

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
if config.dap.adapter ~= false then
  ---@TODO: Add nvim-dap to lua-ls lint
  ---@diagnostic disable-next-line: assign-type-mismatch
  dap.adapters.rt_lldb = config.dap.adapter
end

local M = {}

---For the heroes who want to use it
---@param codelldb_path string
---@param liblldb_path string
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
  if not vim.list_contains(cargo_args, message_json) then
    table.insert(cargo_args, message_json)
  end

  for _, value in ipairs(runnable_args.cargoExtraArgs) do
    if not vim.list_contains(cargo_args, value) then
      table.insert(cargo_args, value)
    end
  end

  return cargo_args
end

---@param args RADebuggableArgs
function M.start(args)
  if not pcall(require, 'plenary.job') then
    scheduled_error('plenary.nvim not found.')
    return
  end

  local Job = require('plenary.job')

  local cargo_args = get_cargo_args_from_runnables_args(args)

  vim.notify('Compiling a debug build for debugging. This might take some time...')

  Job
    :new({
      command = 'cargo',
      args = cargo_args,
      cwd = args.workspaceRoot,
      on_exit = function(j, code)
        if code and code > 0 then
          scheduled_error('An error occurred while compiling. Please fix all compilation issues and try again.')
          return
        end

        vim.schedule(function()
          local executables = {}

          for _, value in pairs(j:result()) do
            local artifact = vim.fn.json_decode(value)

            -- only process artifact if it's valid json object and it is a compiler artifact
            if type(artifact) ~= 'table' or artifact.reason ~= 'compiler-artifact' then
              goto loop_end
            end

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
          -- start debugging
          dap.run(dap_config)
        end)
      end,
    })
    :start()
end

return M
