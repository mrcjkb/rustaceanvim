local M = {}

local cargo = require('rustaceanvim.cargo')
local ui = require('rustaceanvim.ui')
local api = vim.api
local ts = vim.treesitter

local rustc = 'rustc'

-- TODO: See if these can be queried from rustc?
M.available_unpretty = {
  'normal',
  'identified',
  'expanded',
  'expanded,identified',
  'expanded,hygiene',
  'ast-tree',
  'ast-tree,expanded',
  'hir',
  'hir,identified',
  'hir,typed',
  'hir-tree',
  'thir-tree',
  'thir-flat',
  'mir',
  'stable-mir',
  'mir-cfg',
}
---@alias rustaceanvim.rustcir.level 'normal'| 'identified'| 'expanded'| 'expanded,identified'| 'expanded,hygiene'| 'ast-tree'| 'ast-tree,expanded'| 'hir'| 'hir,identified'| 'hir,typed'| 'hir-tree'| 'thir-tree'| 'thir-flat'| 'mir'| 'stable-mir'| 'mir-cfg'

---@type integer | nil
local latest_buf_id = nil

---Get a compatible vim range (1 index based) from a TS node range.
---
---TS nodes start with 0 and the end col is ending exclusive.
---They also treat a EOF/EOL char as a char ending in the first
---col of the next row.
---comment
---@param range integer[]
---@param buf integer|nil
---@return integer, integer, integer, integer
local function get_vim_range(range, buf)
  ---@type integer, integer, integer, integer
  local srow, scol, erow, ecol = unpack(range)
  srow = srow + 1
  scol = scol + 1
  erow = erow + 1

  if ecol == 0 then
    -- Use the value of the last col of the previous row instead.
    erow = erow - 1
    if not buf or buf == 0 then
      ---@diagnostic disable-next-line: assign-type-mismatch
      ecol = vim.fn.col { erow, '$' } - 1
    else
      ecol = #vim.api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1]
    end
    ecol = math.max(ecol, 1)
  end

  return srow, scol, erow, ecol
end

---@param node TSNode
local function get_rows(node)
  local start_row, _, end_row, _ = get_vim_range({ ts.get_node_range(node) }, 0)
  return vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, true)
end

---@param sc vim.SystemCompleted
local function handler(sc)
  if sc.code ~= 0 then
    vim.notify('rustc unpretty failed' .. sc.stderr, vim.log.levels.ERROR)
    return
  end

  -- check if a buffer with the latest id is already open, if it is then
  -- delete it and continue
  ui.delete_buf(latest_buf_id)

  -- create a new buffer
  latest_buf_id = vim.api.nvim_create_buf(false, true) -- not listed and scratch

  -- split the window to create a new buffer and set it to our window
  ui.split(true, latest_buf_id)

  local lines = vim.split(sc.stdout, '\n')

  -- set filetype to rust for syntax highlighting
  vim.bo[latest_buf_id].filetype = 'rust'
  -- write the expansion content to the buffer
  vim.api.nvim_buf_set_lines(latest_buf_id, 0, 0, false, lines)
end

---@return boolean
local function has_tree_sitter_rust()
  return #api.nvim_get_runtime_file('parser/rust.so', true) > 0
    or require('rustaceanvim.shell').is_windows() and #api.nvim_get_runtime_file('parser/rust.dll', true) > 0
end

---@param level rustaceanvim.rustcir.level
function M.rustc_unpretty(level)
  if not has_tree_sitter_rust() then
    vim.notify("a treesitter parser for Rust is required for 'rustc unpretty'", vim.log.levels.ERROR)
    return
  end
  if vim.fn.executable(rustc) ~= 1 then
    vim.notify('rustc is needed to rustc unpretty.', vim.log.levels.ERROR)
    return
  end

  local text

  local cursor = api.nvim_win_get_cursor(0)
  local pos = { math.max(cursor[1] - 1, 0), cursor[2] }

  local cline = api.nvim_get_current_line()
  if not string.find(cline, 'fn%s+') then
    local temp = vim.fn.searchpos('fn ', 'bcn', vim.fn.line('w0'))
    pos = { math.max(temp[1] - 1, 0), temp[2] }
  end

  local node = ts.get_node { pos = pos }

  if node == nil or node:type() ~= 'function_item' then
    vim.notify('no function found or function is incomplete', vim.log.levels.ERROR)
    return
  end

  local b = get_rows(node)
  if b == nil then
    vim.notify('get code text failed', vim.log.levels.ERROR)
    return
  end
  text = table.concat(b, '\n')

  vim.system({
    rustc,
    '--crate-type',
    'lib',
    '--edition',
    cargo.get_rustc_edition(),
    '-Z',
    'unstable-options',
    '-Z',
    'unpretty=' .. level,
    '-',
  }, { stdin = text }, vim.schedule_wrap(handler))
end

return M
