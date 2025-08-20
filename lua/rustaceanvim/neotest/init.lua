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

local cargo = require('rustaceanvim.cargo')
local config = require('rustaceanvim.config.internal')
local lib = require('neotest.lib')
local nio = require('nio')
local overrides = require('rustaceanvim.overrides')
local trans = require('rustaceanvim.neotest.trans')

---@package
---@type neotest.Adapter
---@diagnostic disable-next-line missing-fields
local NeotestAdapter = { name = 'rustaceanvim' }

---@package
---@param file_name string
---@return string | nil
NeotestAdapter.root = function(file_name)
  return cargo.get_config_root_dir(config.server, file_name)
end

---@package
---@param rel_path string Path to directory, relative to root
---@return boolean
NeotestAdapter.filter_dir = function(_, rel_path, _)
  return rel_path ~= 'target'
end

---@package
---@param file_path string
---@return boolean
NeotestAdapter.is_test_file = function(file_path)
  return vim.endswith(file_path, '.rs')
end

---@package
---@class rustaceanvim.neotest.Position: neotest.Position
---@field runnable? rustaceanvim.RARunnable

----@param name string
----@return integer
local function find_buffer_by_name(name)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    if buf_name == name then
      return bufnr
    end
  end
  return 0
end

---@package
---@class nio.rustaceanvim.Client: nio.lsp.Client
---@field request nio.rustaceanvim.RequestClient Interface to all requests that can be sent by the client
---@field config vim.lsp.ClientConfig

---@package
---@class nio.rustaceanvim.RequestClient: nio.lsp.RequestClient
---@field experimental_runnables fun(args: nio.lsp.types.ImplementationParams, bufnr: integer?, opts: nio.lsp.RequestOpts): nio.lsp.types.ResponseError|nil, rustaceanvim.RARunnable[]|nil

---@package
---@param file_path string
---@return neotest.Tree
NeotestAdapter.discover_positions = function(file_path)
  ---@type rustaceanvim.neotest.Position[]
  local positions = {}

  local lsp_client = require('rustaceanvim.rust_analyzer').get_client_for_file(file_path, 'experimental/runnables')
  if not lsp_client then
    ---@diagnostic disable-next-line: missing-parameter
    return lib.positions.parse_tree(positions)
  end
  local nio_client = nio.lsp.get_client_by_id(lsp_client.id)
  ---@cast nio_client nio.rustaceanvim.Client
  local bufnr = find_buffer_by_name(file_path)
  local params = {
    textDocument = {
      uri = vim.uri_from_fname(file_path),
    },
    position = nil,
  }
  local err, runnables = nio_client.request.experimental_runnables(params, bufnr, {
    timeout = 100000,
  })

  if err or type(runnables) ~= 'table' or #runnables == 0 then
    ---@diagnostic disable-next-line: missing-parameter
    return lib.positions.parse_tree(positions)
  end

  local max_end_row = 0
  for _, runnable in pairs(runnables) do
    local pos = trans.runnable_to_position(file_path, runnable)
    if pos then
      max_end_row = math.max(max_end_row, pos.range[3])
      if pos.type ~= 'dir' then
        table.insert(positions, pos)
      end
    end
  end
  ---@diagnostic disable-next-line: cast-type-mismatch
  ---@cast runnables rustaceanvim.RARunnable[]

  ---@type { [string]: neotest.Position }
  local tests_by_name = {}
  ---@type rustaceanvim.neotest.Position[]
  local namespaces = {}
  for _, pos in pairs(positions) do
    if pos.type == 'test' then
      tests_by_name[pos.name] = pos
    elseif pos.type == 'namespace' then
      table.insert(namespaces, pos)
    end
  end

  -- sort namespaces by name from longest to shortest
  table.sort(namespaces, function(a, b)
    return #a.name > #b.name
  end)

  ---@type { [string]: rustaceanvim.neotest.Position[] }
  local positions_by_namespace = {}
  -- group tests by their longest matching namespace
  for _, namespace in ipairs(namespaces) do
    if namespace.name ~= '' then
      ---@type string[]
      local child_keys = vim.tbl_filter(function(name)
        return vim.startswith(name, namespace.name .. '::')
      end, vim.tbl_keys(tests_by_name))
      local children = { namespace }
      for _, key in ipairs(child_keys) do
        local child_pos = tests_by_name[key]
        tests_by_name[key] = nil
        --- strip the namespace and "::" from the name
        child_pos.name = child_pos.name:sub(#namespace.name + 3, #child_pos.name)
        table.insert(children, child_pos)
      end
      positions_by_namespace[namespace.name] = children
    end
  end

  -- nest child namespaces in their parent namespace
  for i, namespace in ipairs(namespaces) do
    ---@type rustaceanvim.neotest.Position?
    local parent = nil
    -- search remaning namespaces for the longest matching parent namespace
    for _, other_namespace in ipairs { unpack(namespaces, i + 1) } do
      if vim.startswith(namespace.name, other_namespace.name .. '::') then
        parent = other_namespace
        break
      end
    end
    if parent ~= nil then
      local namespace_name = namespace.name
      local children = positions_by_namespace[namespace_name]
      -- strip parent namespace + "::"
      children[1].name = children[1].name:sub(#parent.name + 3, #namespace_name)
      table.insert(positions_by_namespace[parent.name], children)
      positions_by_namespace[namespace_name] = nil
    end
  end

  local sorted_positions = {}
  for _, namespace_positions in pairs(positions_by_namespace) do
    table.insert(sorted_positions, namespace_positions)
  end
  -- any remaning tests had no parent namespace
  vim.list_extend(sorted_positions, vim.tbl_values(tests_by_name))

  -- sort positions by their start range
  local function sort_positions(to_sort)
    for _, item in ipairs(to_sort) do
      if vim.islist(item) then
        sort_positions(item)
      end
    end

    -- pop header from the list before sorting since it's used to sort in its parent's context
    local header = table.remove(to_sort, 1)
    table.sort(to_sort, function(a, b)
      local a_item = vim.islist(a) and a[1] or a
      local b_item = vim.islist(b) and b[1] or b
      if a_item.range[1] == b_item.range[1] then
        return a_item.name < b_item.name
      else
        return a_item.range[1] < b_item.range[1]
      end
    end)
    table.insert(to_sort, 1, header)
  end
  sort_positions(sorted_positions)

  local file_pos = {
    id = file_path,
    name = vim.fn.fnamemodify(file_path, ':t'),
    type = 'file',
    path = file_path,
    range = { 0, 0, max_end_row, 0 },
    -- use the shortest namespace for the file runnable
    runnable = #namespaces > 0 and namespaces[#namespaces].runnable or nil,
  }
  table.insert(sorted_positions, 1, file_pos)

  return require('neotest.types.tree').from_list(sorted_positions, function(x)
    return x.name
  end)
end

---@package
---@class rustaceanvim.neotest.RunSpec: neotest.RunSpec
---@field context rustaceanvim.neotest.RunContext

---@package
---@class rustaceanvim.neotest.RunContext
---@field file string
---@field pos_id string
---@field type neotest.PositionType
---@field tree neotest.Tree
---@field workspace_root string?
---@field is_cargo_test boolean

---@package
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
  local exe, args, cwd, env = require('rustaceanvim.runnables').get_command(runnable)
  local context = {
    file = pos.path,
    pos_id = pos.id,
    type = pos.type,
    tree = tree,
    workspace_root = NeotestAdapter.root(pos.path),
    is_cargo_test = args[1] == 'test',
  }
  if run_args.strategy == 'dap' then
    local dap = require('rustaceanvim.dap')
    overrides.sanitize_command_for_debugging(runnable.args.cargoArgs)
    local future = nio.control.future()
    ---@diagnostic disable-next-line: invisible
    dap.start(runnable.args, false, function(strategy)
      future.set(strategy)
    end, function(err)
      future.set_error(err)
    end)
    local ok, strategy = pcall(future.wait)
    local run_spec
    if not ok then
      ---@cast strategy string
      lib.notify(strategy, vim.log.levels.ERROR)
      run_spec = {
        cwd = cwd,
        context = context,
      }
    else
      ---@cast strategy rustaceanvim.dap.client.Config
      ---@type rustaceanvim.neotest.RunSpec
      ---@diagnostic disable-next-line
      run_spec = {
        cwd = cwd,
        context = context,
        strategy = strategy,
      }
    end
    return run_spec
  else
    overrides.undo_debug_sanitize(runnable.args.cargoArgs)
  end
  local insert_pos = context.is_cargo_test and 2 or 3
  table.insert(args, insert_pos, '--no-fail-fast')
  ---@type rustaceanvim.neotest.RunSpec
  ---@diagnostic disable-next-line: missing-fields
  local run_spec = {
    command = vim.list_extend({ exe }, args),
    cwd = cwd,
    context = context,
    env = env,
  }
  return run_spec
end

---@package
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

---@package
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
  if strategy_result.code == 0 then
    results[ctx_pos_id] = {
      status = 'passed',
      output = strategy_result.output,
    }
    return results
  end

  ---@type rustaceanvim.Diagnostic[]
  local diagnostics
  local output_content = ''
  local junit_xml = ''
  if context.is_cargo_test then
    local success
    success, output_content = pcall(function()
      return lib.files.read(strategy_result.output)
    end)
    if not success then
      vim.notify('Failed to read output file', vim.log.levels.ERROR)
      return results
    end
    diagnostics = require('rustaceanvim.test').parse_cargo_test_diagnostics(output_content, 0)
  else
    local success
    success, junit_xml = pcall(function()
      return lib.files.read(
        vim.fs.joinpath(context.workspace_root or vim.fn.getcwd(), 'target', 'nextest', 'rustaceanvim', 'junit.xml')
      )
    end)
    if not success then
      vim.notify('Failed to read junit.xml file', vim.log.levels.ERROR)
      return results
    end
    diagnostics = require('rustaceanvim.test').parse_nextest_diagnostics(junit_xml, 0)
  end

  if not vim.tbl_contains({ 'file', 'test', 'namespace' }, context.type) then
    return results
  end
  results[ctx_pos_id] = {
    status = 'failed',
    output = strategy_result.output,
  }

  if vim.tbl_isempty(diagnostics) then
    return results -- no failures
  end

  for _, node in get_file_root(context.tree):iter_nodes() do
    local data = node:data()
    local failure_diagnostic = vim.iter(diagnostics):find(function(diag)
      return vim.endswith(data.id, diag.test_id)
    end)

    if failure_diagnostic then
      results[data.id] = {
        status = 'failed',
        errors = { { line = failure_diagnostic.lnum, message = failure_diagnostic.message } },
        short = failure_diagnostic.message,
      }
    elseif data.type == 'test' then
      -- Initialise as skipped. Passed positions will be parsed and set later.
      results[data.id] = {
        status = 'skipped',
      }
    end
  end

  if context.is_cargo_test then
    require('rustaceanvim.neotest.parser').populate_pass_positions_cargo_test(results, context, output_content)
  else
    require('rustaceanvim.neotest.parser').populate_pass_positions_nextest(results, context, junit_xml)
  end
  return results
end

setmetatable(NeotestAdapter, {
  __call = function()
    return NeotestAdapter
  end,
})

return NeotestAdapter
