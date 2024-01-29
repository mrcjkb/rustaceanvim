local M = {}

---@param bufnr integer | nil
function M.delete_buf(bufnr)
  if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

---@param winnr integer | nil
function M.close_win(winnr)
  if winnr ~= nil and vim.api.nvim_win_is_valid(winnr) then
    vim.api.nvim_win_close(winnr, true)
  end
end

---@param vertical boolean
---@param bufnr integer
function M.split(vertical, bufnr)
  local cmd = vertical and 'vsplit' or 'split'

  vim.cmd(cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, bufnr)
end

---@param vertical boolean
---@param amount string
function M.resize(vertical, amount)
  local cmd = vertical and 'vertical resize ' or 'resize'
  cmd = cmd .. amount

  vim.cmd(cmd)
end

-- Converts a tuple of range coordinates into LSP's position argument
---@param row1 integer
---@param col1 integer
---@param row2 integer
---@param col2 integer
---@return lsp_range
local function make_lsp_position(row1, col1, row2, col2)
  -- Note: vim's lines are 1-indexed, but LSP's are 0-indexed
  return {
    ['start'] = {
      line = row1 - 1,
      character = col1,
    },
    ['end'] = {
      line = row2 - 1,
      character = col2,
    },
  }
end

---@return lsp_range | nil
function M.get_visual_selected_range()
  -- Taken from https://github.com/neovim/neovim/pull/13896#issuecomment-774680224
  local p1 = vim.fn.getpos('v')
  if not p1 then
    return nil
  end
  local row1 = p1[2]
  local col1 = p1[3]
  local p2 = vim.api.nvim_win_get_cursor(0)
  local row2 = p2[1]
  local col2 = p2[2]

  if row1 < row2 then
    return make_lsp_position(row1, col1, row2, col2)
  elseif row2 < row1 then
    return make_lsp_position(row2, col2, row1, col1)
  end

  return make_lsp_position(row1, math.min(col1, col2), row1, math.max(col1, col2))
end

return M
