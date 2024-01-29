local M = {}

local config = require('rustaceanvim.config.internal')
local compat = require('rustaceanvim.compat')
local ui = require('rustaceanvim.ui')

local rustc = 'rustc'

---@class DiagnosticWindowState
local _window_state = {
  ---@type integer | nil
  float_winnr = nil,
  ---@type integer | nil
  latest_scratch_buf_id = nil,
}

---@param bufnr integer
---@param winnr integer
---@param lines string[]
local function set_open_split_keymap(bufnr, winnr, lines)
  local function open_split()
    -- check if a buffer with the latest id is already open, if it is then
    -- delete it and continue
    ui.delete_buf(_window_state.latest_scratch_buf_id)

    -- create a new buffer
    _window_state.latest_scratch_buf_id = vim.api.nvim_create_buf(false, true) -- not listed and scratch

    -- split the window to create a new buffer and set it to our window
    ui.split(false, _window_state.latest_scratch_buf_id)

    -- set filetype to rust for syntax highlighting
    vim.bo[_window_state.latest_scratch_buf_id].filetype = 'rust'
    -- write the expansion content to the buffer
    vim.api.nvim_buf_set_lines(_window_state.latest_scratch_buf_id, 0, 0, false, lines)
  end
  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_win_get_cursor(winnr)[1]
    if line > 1 then
      return
    end
    open_split()
  end, { buffer = bufnr, noremap = true, silent = true })
end

---@return nil
local function close_hover()
  local winnr = _window_state.float_winnr
  if winnr ~= nil and vim.api.nvim_win_is_valid(winnr) then
    vim.api.nvim_win_close(winnr, true)
    _window_state.float_winnr = nil
  end
end

---@param bufnr integer
local function set_close_keymaps(bufnr)
  vim.keymap.set('n', 'q', close_hover, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<Esc>', close_hover, { buffer = bufnr, noremap = true, silent = true })
end

function M.explain_error()
  if vim.fn.executable(rustc) ~= 1 then
    vim.notify('rustc is needed to explain errors.', vim.log.levels.ERROR)
    return
  end

  local diagnostics = vim.tbl_filter(function(diagnostic)
    return diagnostic.code ~= nil
      and diagnostic.source == 'rustc'
      and diagnostic.severity == vim.diagnostic.severity.ERROR
  end, vim.diagnostic.get(0, {}))
  if #diagnostics == 0 then
    vim.notify('No explainable errors found.', vim.log.levels.INFO)
    return
  end
  local win_id = vim.api.nvim_get_current_win()
  local opts = {
    cursor_position = vim.api.nvim_win_get_cursor(win_id),
    severity = vim.diagnostic.severity.ERROR,
    wrap = true,
  }
  local found = false
  local diagnostic
  local pos_map = {}
  local pos_id = 1
  repeat
    diagnostic = vim.diagnostic.get_next(opts)
    pos_map[pos_id] = diagnostic
    if diagnostic == nil then
      break
    end
    found = diagnostic.code ~= nil and diagnostic.source == 'rustc'
    local pos = { diagnostic.lnum, diagnostic.col }
    pos_id = pos[1] + pos[2]
    opts.cursor_position = pos
    local searched_all = pos_map[pos_id] ~= nil
  until diagnostic == nil or found or searched_all
  if not found then
    -- Fall back to first diagnostic
    diagnostic = diagnostics[1]
    local pos = { diagnostic.lnum, diagnostic.col }
    opts.cursor_position = pos
    return
  end

  ---@param sc vim.SystemCompleted
  local function handler(sc)
    if sc.code ~= 0 or not sc.stdout then
      vim.notify('Error calling rustc --explain' .. (sc.stderr and ': ' .. sc.stderr or ''), vim.log.levels.ERROR)
      return
    end
    local output = sc.stdout:gsub('```', '```rust', 1)
    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(output, {})
    local float_preview_lines = vim.deepcopy(markdown_lines)
    table.insert(float_preview_lines, 1, '---')
    table.insert(float_preview_lines, 1, '1. Open in split')
    vim.schedule(function()
      close_hover()
      local bufnr, winnr = vim.lsp.util.open_floating_preview(
        float_preview_lines,
        'markdown',
        vim.tbl_extend('keep', config.tools.float_win_config, {
          focus = false,
          focusable = true,
          focus_id = 'rustc-explain-error',
          close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
        })
      )
      _window_state.float_winnr = winnr
      set_close_keymaps(bufnr)
      set_open_split_keymap(bufnr, winnr, markdown_lines)

      if config.tools.float_win_config.auto_focus then
        vim.api.nvim_set_current_win(winnr)
      end
    end)
  end

  -- Save position in the window's jumplist
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(win_id, { diagnostic.lnum + 1, diagnostic.col })
  -- Open folds under the cursor
  vim.cmd('normal! zv')
  compat.system({ rustc, '--explain', diagnostic.code }, nil, vim.schedule_wrap(handler))
end

---@param diagnostic table
---@return string | nil
local function get_rendered_diagnostic(diagnostic)
  local result = vim.tbl_get(diagnostic, 'user_data', 'lsp', 'data', 'rendered')
  if type(result) == 'string' then
    ---@diagnostic disable-next-line: cast-type-mismatch
    ---@cast result string
    return result
  end
end

function M.render_diagnostic()
  local diagnostics = vim.tbl_filter(function(diagnostic)
    return get_rendered_diagnostic(diagnostic) ~= nil
  end, vim.diagnostic.get(0, {}))
  if #diagnostics == 0 then
    vim.notify('No renderable diagnostics found.', vim.log.levels.INFO)
    return
  end
  local win_id = vim.api.nvim_get_current_win()
  local opts = {
    cursor_position = vim.api.nvim_win_get_cursor(win_id),
    wrap = true,
  }
  local rendered_diagnostic
  local diagnostic
  local pos_map = {}
  local pos_id = 1
  repeat
    diagnostic = vim.diagnostic.get_next(opts)
    pos_map[pos_id] = diagnostic
    if diagnostic == nil then
      break
    end
    rendered_diagnostic = get_rendered_diagnostic(diagnostic)
    local pos = { diagnostic.lnum, diagnostic.col }
    pos_id = pos[1] + pos[2]
    opts.cursor_position = pos
    local searched_all = pos_map[pos_id] ~= nil
  until diagnostic == nil or rendered_diagnostic ~= nil or searched_all
  if not rendered_diagnostic then
    -- No diagnostics found. Fall back to first result from filter,
    rendered_diagnostic = get_rendered_diagnostic(diagnostics[1])
    ---@cast rendered_diagnostic string
  end

  -- Save position in the window's jumplist
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(win_id, { diagnostic.lnum + 1, diagnostic.col })
  -- Open folds under the cursor
  vim.cmd('normal! zv')

  local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(rendered_diagnostic, {})
  local float_preview_lines = vim.deepcopy(markdown_lines)
  table.insert(float_preview_lines, 1, '---')
  table.insert(float_preview_lines, 1, '1. Open in split')
  vim.schedule(function()
    close_hover()
    local bufnr, winnr = vim.lsp.util.open_floating_preview(
      float_preview_lines,
      'markdown',
      vim.tbl_extend('keep', config.tools.float_win_config, {
        focus = false,
        focusable = true,
        focus_id = 'ra-render-diagnostic',
        close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
      })
    )
    _window_state.float_winnr = winnr
    set_close_keymaps(bufnr)
    set_open_split_keymap(bufnr, winnr, markdown_lines)
    if config.tools.float_win_config.auto_focus then
      vim.api.nvim_set_current_win(winnr)
    end
  end)
end

return M
