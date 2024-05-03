---@diagnostic disable: deprecated, duplicate-doc-field, duplicate-doc-alias
---@mod rustaceanvim.compat Functions for backward compatibility with older Neovim versions
---                         and with compatibility type annotations to make the type checker
---                         happy for both stable and nightly neovim versions.

local M = {}

M.joinpath = vim.fs.joinpath or function(...)
  return (table.concat({ ... }, '/'):gsub('//+', '/'))
end

---@class vim.lsp.get_clients.Filter
---@field id integer|nil Match clients by id
---@field bufnr integer|nil match clients attached to the given buffer
---@field name string|nil match clients by name
---@field method string|nil match client by supported method name

---@alias vim.lsp.get_active_clients.filter vim.lsp.get_clients.Filter
---@alias lsp.Client vim.lsp.Client
---@alias lsp.ClientConfig vim.lsp.ClientConfig

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

M.uv = vim.uv or vim.loop

--- @enum vim.diagnostic.Severity
M.severity = {
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  HINT = 4,
  [1] = 'ERROR',
  [2] = 'WARN',
  [3] = 'INFO',
  [4] = 'HINT',
}

--- @class vim.Diagnostic
--- @field bufnr? integer
--- @field lnum integer 0-indexed
--- @field end_lnum? integer 0-indexed
--- @field col integer 0-indexed
--- @field end_col? integer 0-indexed
--- @field severity? vim.diagnostic.Severity
--- @field message string
--- @field source? string
--- @field code? string
--- @field _tags? { deprecated: boolean, unnecessary: boolean}
--- @field user_data? any arbitrary data plugins can add
--- @field namespace? integer

--- @class vim.api.keyset.user_command
--- @field addr? any
--- @field bang? boolean
--- @field bar? boolean
--- @field complete? any
--- @field count? any
--- @field desc? any
--- @field force? boolean
--- @field keepscript? boolean
--- @field nargs? any
--- @field preview? any
--- @field range? any
--- @field register? boolean

--- @class vim.SystemCompleted
--- @field code integer
--- @field signal integer
--- @field stdout? string
--- @field stderr? string

M.system = vim.system
  -- wrapper around vim.fn.system to give it a similar API to vim.system
  or function(cmd, opts, on_exit)
    ---@cast cmd string[]
    ---@cast opts vim.SystemOpts | nil
    ---@cast on_exit fun(sc: vim.SystemCompleted) | nil
    ---@diagnostic disable-next-line: undefined-field
    if opts and opts.cwd then
      local shell = require('rustaceanvim.shell')
      ---@diagnostic disable-next-line: undefined-field
      cmd = shell.chain_commands { shell.make_cd_command(opts.cwd), table.concat(cmd, ' ') }
      ---@cast cmd string
    end

    local output = vim.fn.system(cmd)
    local ok = vim.v.shell_error
    ---@type vim.SystemCompleted
    local systemObj = {
      signal = 0,
      stdout = ok and (output or '') or nil,
      stderr = not ok and (output or '') or nil,
      code = vim.v.shell_error,
    }
    if on_exit then
      on_exit(systemObj)
    end
    return systemObj
  end

M.list_contains = vim.list_contains
  or function(t, value)
    vim.validate { t = { t, 't' } }
    for _, v in ipairs(t) do
      if v == value then
        return true
      end
    end
    return false
  end

---@alias lsp.Handler fun(err: lsp.ResponseError?, result: any, context: lsp.HandlerContext, config?: table): ...any

M.islist = vim.islist or vim.tbl_islist

return M
