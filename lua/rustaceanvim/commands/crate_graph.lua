local config = require('rustaceanvim.config.internal')

local M = {}

---@return { full: boolean}
local function get_opts()
  return { full = config.tools.crate_graph.full }
end

--- Creation of the correct handler depending on the initial call of the command
--- and give the option to override global settings
---@param backend string | nil
---@param output string | nil
---@param pipe string | nil
---@return fun(err: string, graph: string)
local function handler_factory(backend, output, pipe)
  backend = backend or config.tools.crate_graph.backend
  output = output or config.tools.crate_graph.output
  pipe = pipe or config.tools.crate_graph.pipe

  -- Graph is a representation of the crate graph following the graphviz format
  -- The handler processes and pipes the graph to the dot command that will
  -- visualize with the given backend
  return function(err, graph)
    if err ~= nil then
      vim.notify('Could not execute request to server ' .. (err or ''), vim.log.levels.ERROR)
      return
    end

    -- Validating backend
    if not backend then
      vim.notify('no crate graph backend specified.', vim.log.levels.ERROR)
      return
    end
    if not vim.list_contains(config.tools.crate_graph.enabled_graphviz_backends, backend) then
      vim.notify('crate graph backend not recognized as valid: ' .. vim.inspect(backend), vim.log.levels.ERROR)
      return
    end

    graph = string.gsub(graph, '\n', '')
    vim.notify('rustaceanvim: Processing crate graph. This may take a while...')

    local cmd = 'dot -T' .. backend
    if pipe ~= nil then -- optionally pipe to `pipe`
      cmd = cmd .. ' | ' .. pipe
    end
    if output ~= nil then -- optionally redirect to `output`
      cmd = cmd .. ' > ' .. output
    end

    -- Execute dot command to generate the output graph
    -- Needs to be handled with care to prevent security problems
    local handle, err_ = io.popen(cmd, 'w')
    if not handle then
      vim.notify('Could not create crate graph ' .. (err_ or ''), vim.log.levels.ERROR)
      return
    end
    handle:write(graph)

    -- needs to be here otherwise dot may take a long time before it gets
    -- any input + cleaning up (not waiting for garbage collection)
    handle:flush()
    handle:close()
  end
end

local rl = require('rustaceanvim.rust_analyzer')

---@param backend string | nil
---@param output string | nil
---@param pipe string | nil
function M.view_crate_graph(backend, output, pipe)
  rl.buf_request(0, 'rust-analyzer/viewCrateGraph', get_opts(), handler_factory(backend, output, pipe))
end

return M.view_crate_graph
