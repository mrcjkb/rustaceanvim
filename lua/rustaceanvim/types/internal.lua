---@alias lsp_position { character: integer, line: integer }
---@alias lsp_range { start: lsp_position, end: lsp_position }
---@alias lsp_text_document { uri: string }
---@alias lsp_range_params { textDocument: lsp_text_document, range: lsp_range }
---@alias lsp_position_params { textDocument: lsp_text_document, position: lsp_position }

local M = {}

---Evaluate a value that may be a function
---or an evaluated value
---@generic T
---@param value (fun():T)|T
---@return T
M.evaluate = function(value)
  if type(value) == 'function' then
    return value()
  end
  return value
end

return M
