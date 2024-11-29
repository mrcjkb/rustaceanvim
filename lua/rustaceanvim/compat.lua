---@diagnostic disable: deprecated, duplicate-doc-alias

---@mod rustaceanvim.compat compativility layer for
---API calls that are deprecated or removed in nvim nightly

local compat = {}

---@return lsp.Diagnostic[]
function compat.get_line_diagnostics()
  if vim.lsp.diagnostic.from then
    local opts = {
      lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
    }
    return vim.lsp.diagnostic.from(vim.diagnostic.get(0, opts))
  end
  ---@diagnostic disable-next-line: deprecated
  return vim.lsp.diagnostic.get_line_diagnostics()
end

---@param location lsp.Location|lsp.LocationLink
---@param offset_encoding 'utf-8'|'utf-16'|'utf-32'?
---@return boolean `true` if the jump succeeded
function compat.show_document(location, offset_encoding)
  local show_document = vim.lsp.show_document
  if not show_document then
    return vim.lsp.util.jump_to_location(location, offset_encoding or 'utf-8')
  end
  return show_document(location, offset_encoding or 'utf-8', { focus = true })
end

--- @param client vim.lsp.Client
--- @param method string LSP method name.
--- @param params? table LSP request params.
--- @param handler? lsp.Handler Response |lsp-handler| for this method.
--- @param bufnr? integer Buffer handle. 0 for current (default).
--- @return boolean status indicates whether the request was successful.
---     If it is `false`, then it will always be `false` (the client has shutdown).
--- @return integer? request_id Can be used with |Client:cancel_request()|.
---                             `nil` is request failed.
--- to cancel the-request.
function compat.client_request(client, method, params, handler, bufnr)
  local info = debug.getinfo(client.request, 'u')
  if info.nparams > 0 then
    ---@diagnostic disable-next-line: param-type-mismatch
    return client:request(method, params, handler, bufnr)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    return client.request(method, params, handler, bufnr)
  end
end

--- @param client vim.lsp.Client
--- @param method string LSP method name.
--- @param params table? LSP request params.
--- @return boolean status indicating if the notification was successful.
---                        If it is false, then the client has shutdown.
function compat.client_notify(client, method, params)
  -- Nothing brings me more joy than updating Neovim nightly
  -- and discovering that my perfectly functioning plugin has been obliterated because
  -- a feature was deprecated without an alternative in stable.
  -- Truly, it's the chaos I live for. (╯°□°）╯︵ ┻━┻
  local info = debug.getinfo(client.notify, 'u')
  if info.nparams > 0 then
    ---@diagnostic disable-next-line: param-type-mismatch
    return client:notify(method, params)
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    return client.notify(method, params)
  end
end

---@param client vim.lsp.Client
---@return boolean
function compat.client_is_stopped(client)
  local info = debug.getinfo(client.is_stopped, 'u')
  if info.nparams > 0 then
    ---@diagnostic disable-next-line: param-type-mismatch
    return client:is_stopped()
  else
    ---@diagnostic disable-next-line: missing-parameter
    return client.is_stopped()
  end
end

return compat
