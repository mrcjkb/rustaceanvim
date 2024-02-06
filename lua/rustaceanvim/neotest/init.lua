---@mod rustaceanvim.neotest
---
---@brief [[
---
---A |neotest| adapter for rust, powered by rustaceanvim.
---
---If you add this to neotest:
---
--->
---require('neotest').setup {
---    -- ...,
---    adapters = {
---      -- ...,
---      require('rustaceanvim.neotest')
---    },
---}
---<
---
---this plugin will configure itself to use |neotest|
---as a test executor, and |neotest| will use rust-analyzer
---for test discovery and command construction.
---
---Note: If you use this adapter, do not add the neotest-rust adapter
---(another plugin).
---
---@brief ]]

---@diagnostic disable: duplicate-set-field

local lib = require('neotest.lib')
local nio = require('nio')
local trans = require('rustaceanvim.neotest.trans')
local cargo = require('rustaceanvim.cargo')

---@type neotest.Adapter
local NeotestAdapter = { name = 'rustaceanvim' }

---@param file_name string
---@return string | nil
NeotestAdapter.root = function(file_name)
  return cargo.get_root_dir(file_name)
end

---@param file_path string
---@return boolean
NeotestAdapter.is_test_file = function(file_path)
  return vim.endswith(file_path, '.rs')
end

---@class rustaceanvim.neotest.Position: neotest.Position
---@field runnable? RARunnable

---@param file_path string
---@return neotest.Tree
NeotestAdapter.discover_positions = function(file_path)
  ---@type rustaceanvim.neotest.Position[]
  local positions = {}
  local rust_analyzer = require('rustaceanvim.rust_analyzer')
  local future = nio.control.future()
  rust_analyzer.file_request(file_path, 'experimental/runnables', nil, function(err, runnables)
    if err then
      future.set_error(err)
    else
      future.set(runnables)
    end
  end)
  local ok, runnables = pcall(future.wait)
  if not ok or type(runnables) ~= 'table' or #runnables == 0 then
    ---@diagnostic disable-next-line: missing-parameter
    return lib.positions.parse_tree(positions)
  end
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast runnables RARunnable[]
  -- We need a runnable for the 'file' position, so we pick the first 'namespace' one
  -- Typically, a file only has one test module
  ---@type RARunnable
  local crate_runnable = nil
  local max_end_row = 0
  for _, runnable in pairs(runnables) do
    local pos = trans.runnable_to_position(file_path, runnable)
    if pos then
      max_end_row = math.max(max_end_row, pos.range[3])
      if pos.type == 'dir' then
        crate_runnable = runnable
      else
        table.insert(positions, pos)
      end
    end
  end
  -- parse_tree expects sorted positions, with the parent first
  ---@type rustaceanvim.neotest.Position[]
  local sorted_positions = {}
  ---@type { [string]: neotest.Position }
  local tests_by_name = {}
  -- If there's only one module in a file, we use it as the file runnable
  local namespace_runnable
  local namespace_count = 0
  for _, pos in pairs(positions) do
    if pos.type == 'test' then
      tests_by_name[pos.name] = pos
    end
  end
  local test_names = vim.tbl_keys(tests_by_name)
  for _, namespace_pos in pairs(positions) do
    if namespace_pos.type == 'namespace' then
      namespace_runnable = namespace_runnable or namespace_pos.runnable
      namespace_count = namespace_count + 1
      table.insert(sorted_positions, namespace_pos)
      ---@type string[]
      local child_keys = vim.tbl_filter(function(name)
        return vim.startswith(name, namespace_pos.name)
      end, test_names)
      for _, key in pairs(child_keys) do
        local child_pos = tests_by_name[key]
        --- strip the namespace and "::" from the name so neotest can build the Tree
        child_pos.name = child_pos.name:sub(namespace_pos.name:len() + 3, child_pos.name:len())
        table.insert(sorted_positions, child_pos)
      end
    end
  end
  if namespace_runnable then
    local file_pos = {
      id = file_path,
      name = file_path,
      type = 'file',
      path = file_path,
      range = { 0, 0, max_end_row, 0 },
      runnable = namespace_runnable,
    }
    table.insert(sorted_positions, 1, file_pos)
  end
  if crate_runnable and #sorted_positions > 0 then
    -- Only insert a crate runnable position if there exist positions
    local crate_pos = {
      id = 'rustaceanvim:' .. crate_runnable.args.workspaceRoot,
      name = 'suite',
      type = 'dir',
      path = crate_runnable.args.workspaceRoot,
      range = { 0, 0, 0, 0 },
      runnable = crate_runnable,
    }
    table.insert(sorted_positions, 1, crate_pos)
  end
  ---@diagnostic disable-next-line: missing-parameter
  return lib.positions.parse_tree(sorted_positions)
end

---@class rustaceanvim.neotest.RunSpec: neotest.RunSpec
---@field context rustaceanvim.neotest.RunContext

---@class rustaceanvim.neotest.RunContext
---@field file string
---@field pos_id string
---@field type neotest.PositionType
---@field tree neotest.Tree

---@param run_args neotest.RunArgs
---@return neotest.RunSpec|nil
---@private
function NeotestAdapter.build_spec(run_args)
  local supported_types = { 'test', 'namespace', 'file', 'dir' }
  local tree = run_args and run_args.tree
  if not tree then
    return
  end
  local pos = tree:data()
  ---@cast pos rustaceanvim.neotest.Position
  if not vim.tbl_contains(supported_types, pos.type) then
    return
  end
  local runnable = pos.runnable
  if not runnable then
    return
  end
  local context = {
    file = pos.path,
    pos_id = pos.id,
    type = pos.type,
    tree = tree,
  }
  local exe, args, cwd = require('rustaceanvim.runnables').get_command(runnable)
  if run_args.strategy == 'dap' then
    local dap = require('rustaceanvim.dap')
    local overrides = require('rustaceanvim.overrides')
    overrides.sanitize_command_for_debugging(runnable.args.cargoArgs)
    local future = nio.control.future()
    dap.start(runnable.args, false, function(strategy)
      future.set(strategy)
    end, function(err)
      future.set_error(err)
    end)
    local ok, strategy = pcall(future.wait)
    if not ok then
      ---@cast strategy string
      lib.notify(strategy, vim.log.levels.ERROR)
    end
    ---@cast strategy DapClientConfig
    ---@type rustaceanvim.neotest.RunSpec
    local run_spec = {
      cwd = cwd,
      context = context,
      strategy = strategy,
    }
    return run_spec
  end
  ---@type rustaceanvim.neotest.RunSpec
  ---@diagnostic disable-next-line: missing-fields
  local run_spec = {
    command = vim.list_extend({ exe }, args),
    cwd = cwd,
    context = context,
  }
  return run_spec
end

---Get the file root from a test tree.
---@param tree neotest.Tree The test tree.
---@return neotest.Tree file_root The file root position.
local function get_file_root(tree)
  for _, node in tree:iter_parents() do
    local data = node and node:data()
    if data and not vim.tbl_contains({ 'test', 'namespace' }, data.type) then
      return node
    end
  end
  return tree
end

---@param spec neotest.RunSpec
---@param strategy_result neotest.StrategyResult
---@return table<string, neotest.Result> results
function NeotestAdapter.results(spec, strategy_result)
  ---@type table<string, neotest.Result>
  local results = {}
  ---@type rustaceanvim.neotest.RunContext
  local context = spec.context
  local ctx_pos_id = context.pos_id
  ---@type string
  local output_content = lib.files.read(strategy_result.output)
  if strategy_result.code == 0 then
    results[ctx_pos_id] = {
      status = 'passed',
      output = strategy_result.output,
    }
    return results
  end
  ---@type table<string,neotest.Error[]>
  local errors_by_test_id = {}
  output_content = output_content:gsub('\r\n', '\n')
  local diagostics = require('rustaceanvim.test').parse_diagnostics(context.file, output_content)
  for _, diagnostic in pairs(diagostics) do
    ---@type neotest.Error
    local err = {
      line = diagnostic.lnum,
      message = diagnostic.message,
    }
    errors_by_test_id[diagnostic.test_id] = errors_by_test_id[diagnostic.test_id] or {}
    table.insert(errors_by_test_id[diagnostic.test_id], err)
  end
  if not vim.tbl_contains({ 'file', 'test', 'namespace' }, context.type) then
    return results
  end
  results[ctx_pos_id] = {
    status = 'failed',
    output = strategy_result.output,
  }
  for _, node in get_file_root(context.tree):iter_nodes() do
    local data = node:data()
    for test_id, errors in pairs(errors_by_test_id) do
      if vim.endswith(data.id, test_id) then
        results[data.id] = {
          status = 'failed',
          errors = errors,
          short = output_content,
        }
      end
    end
  end
  return results
end

setmetatable(NeotestAdapter, {
  __call = function()
    return NeotestAdapter
  end,
})

return NeotestAdapter
