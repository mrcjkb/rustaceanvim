local rl = require('rustaceanvim.rust_analyzer')

local M = {}

---@enum WorkspaceSymbolSearchScope
M.WorkspaceSymbolSearchScope = {
  workspace = 'workspace',
  workspaceAndDependencies = 'workspaceAndDependencies',
}

---@enum WorkspaceSymbolSearchKind
M.WorkspaceSymbolSearchKind = {
  onlyTypes = 'onlyTypes',
  allSymbols = 'allSymbols',
}

---@type WorkspaceSymbolSearchKind
local default_search_kind = M.WorkspaceSymbolSearchKind.allSymbols

---@param searchScope WorkspaceSymbolSearchScope
---@param searchKind WorkspaceSymbolSearchKind
---@param query string
local function get_params(searchScope, searchKind, query)
  return {
    query = query,
    searchScope = searchScope,
    searchKind = searchKind,
  }
end

---@return string | nil
local function query_from_input()
  return vim.F.npcall(vim.fn.input, 'Query: ')
end

---@param searchScope WorkspaceSymbolSearchScope
---@param args? unknown[]
function M.workspace_symbol(searchScope, args)
  local searchKind = default_search_kind
  local query
  if not args or #args == 0 then
    query = query_from_input()
    if query == nil then
      return
    end
    args = {}
  end
  if #args > 0 and M.WorkspaceSymbolSearchKind[args[1]] then
    searchKind = args[1]
    table.remove(args, 1)
  end
  if #args == 0 then
    query = query_from_input()
    if not query then
      return
    end
  else
    query = args[1]
  end
  rl.any_buf_request('workspace/symbol', get_params(searchScope, searchKind, query))
end

return M
