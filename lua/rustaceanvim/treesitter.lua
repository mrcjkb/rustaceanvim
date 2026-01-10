local M = {}

local api = vim.api

---@return boolean
function M.has_tree_sitter_rust()
  return #api.nvim_get_runtime_file('parser/rust.so', true) > 0
    or require('rustaceanvim.shell').is_windows() and #api.nvim_get_runtime_file('parser/rust.dll', true) > 0
end

-- The `rust-analyzer/relatedTests` resolves using the identifier under the cursor,
-- but it is useful to resolve related tests while having the cursor in the function body.
-- This function will recursively search for the parent fn and then descend to find the child
-- identifier, so that the `relatedTest` method works even if the cursor is inside the
-- function.
---@return lsp.Position|nil
function M.find_fn_identifier_position()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_pos = { math.max(cursor[1] - 1, 0), cursor[2] }

  local node = vim.treesitter.get_node { pos = start_pos }
  while node do
    if node:type() == 'function_item' then
      for child in node:iter_children() do
        if child:type() == 'identifier' then
          local start_row, start_col = child:start()
          return { line = start_row, character = start_col }
        end
      end
    end
    node = node:parent()
  end
  return nil
end

return M
