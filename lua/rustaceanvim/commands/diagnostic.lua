local M = {}

local config = require('rustaceanvim.config.internal')
local ui = require('rustaceanvim.ui')

local rustc = 'rustc'

---@class rustaceanvim.diagnostic.WindowState
local _window_state = {
  ---@type integer | nil
  float_winnr = nil,
  ---@type integer | nil
  latest_scratch_buf_id = nil,
}

---@param bufnr integer
---@param winnr integer
---@param render_fn function
local function set_split_open_keymap(bufnr, winnr, render_fn)
  local function open_split()
    -- check if a buffer with the latest id is already open, if it is then
    -- delete it and continue
    ui.delete_buf(_window_state.latest_scratch_buf_id)

    -- create a new buffer
    _window_state.latest_scratch_buf_id = vim.api.nvim_create_buf(false, true) -- not listed and scratch

    -- split the window to create a new buffer and set it to our window
    local vsplit = config.tools.float_win_config.open_split == 'vertical'
    ui.split(vsplit, _window_state.latest_scratch_buf_id)
    render_fn()
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

  local diagnostics = vim
    .iter(vim.diagnostic.get(0, {}))
    ---@param diagnostic vim.Diagnostic
    :filter(function(diagnostic)
      return diagnostic.code ~= nil
        and diagnostic.source == 'rustc'
        and diagnostic.severity == vim.diagnostic.severity.ERROR
    end)
    :totable()
  if #diagnostics == 0 then
    vim.notify('No explainable errors found.', vim.log.levels.INFO)
    return
  end
  close_hover()
  local win_id = vim.api.nvim_get_current_win()
  local opts = {
    cursor_position = vim.api.nvim_win_get_cursor(win_id),
    severity = vim.diagnostic.severity.ERROR,
    wrap = true,
  }
  local found = false
  local diagnostic
  local pos_map = {}
  ---@type string
  local pos_id = '0'
  repeat
    diagnostic = vim.diagnostic.get_next(opts)
    pos_map[pos_id] = diagnostic
    if diagnostic == nil then
      break
    end
    found = diagnostic.code ~= nil and diagnostic.source == 'rustc'
    local pos = { diagnostic.lnum, diagnostic.col }
    -- check if there is an explainable error at the same location
    if not found then
      local cursor_diagnostics = vim.tbl_filter(function(diag)
        return pos[1] == diag.lnum and pos[2] == diag.col
      end, diagnostics)
      if #cursor_diagnostics ~= 0 then
        diagnostic = cursor_diagnostics[1]
        found = true
        break
      end
    end
    pos_id = vim.inspect(pos)
    -- diagnostics are (0,0)-indexed but cursors are (1,0)-indexed
    opts.cursor_position = { pos[1] + 1, pos[2] }
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
      local bufnr, winnr = vim.lsp.util.open_floating_preview(
        float_preview_lines,
        'markdown',
        vim.tbl_extend('keep', config.tools.float_win_config, {
          focus_id = 'rustc-explain-error',
        })
      )
      _window_state.float_winnr = winnr
      set_close_keymaps(bufnr)
      set_split_open_keymap(bufnr, winnr, function()
        -- set filetype to rust for syntax highlighting
        vim.bo[_window_state.latest_scratch_buf_id].filetype = 'rust'
        -- write the expansion content to the buffer
        vim.api.nvim_buf_set_lines(_window_state.latest_scratch_buf_id, 0, 0, false, markdown_lines)
      end)

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
  vim.system({ rustc, '--explain', tostring(diagnostic.code) }, nil, vim.schedule_wrap(handler))
end

function M.explain_error_current_line()
  if vim.fn.executable(rustc) ~= 1 then
    vim.notify('rustc is needed to explain errors.', vim.log.levels.ERROR)
    return
  end

  local win_id = vim.api.nvim_get_current_win()
  local cursor_position = vim.api.nvim_win_get_cursor(win_id)

  -- get matching diagnostics from current line
  local diagnostics = vim
    .iter(vim.diagnostic.get(0, {
      lnum = cursor_position[1] - 1,
    }))
    :filter(function(diagnostic)
      return diagnostic.code ~= nil
        and diagnostic.source == 'rustc'
        and diagnostic.severity == vim.diagnostic.severity.ERROR
    end)
    :totable()

  -- no matching diagnostics on current line
  if #diagnostics == 0 then
    vim.notify('No explainable errors found.', vim.log.levels.INFO)
    return
  end

  local diagnostic = diagnostics[1]

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
      local bufnr, winnr = vim.lsp.util.open_floating_preview(
        float_preview_lines,
        'markdown',
        vim.tbl_extend('keep', config.tools.float_win_config, {
          focus_id = 'rustc-explain-error',
        })
      )
      _window_state.float_winnr = winnr
      set_close_keymaps(bufnr)
      set_split_open_keymap(bufnr, winnr, function()
        -- set filetype to rust for syntax highlighting
        vim.bo[_window_state.latest_scratch_buf_id].filetype = 'rust'
        -- write the expansion content to the buffer
        vim.api.nvim_buf_set_lines(_window_state.latest_scratch_buf_id, 0, 0, false, markdown_lines)
      end)

      if config.tools.float_win_config.auto_focus then
        vim.api.nvim_set_current_win(winnr)
      end
    end)
  end

  vim.system({ rustc, '--explain', tostring(diagnostic.code) }, nil, vim.schedule_wrap(handler))
end

---@param diagnostic vim.Diagnostic
---@return string | nil
local function get_rendered_diagnostic(diagnostic)
  local result = vim.tbl_get(diagnostic, 'user_data', 'lsp', 'data', 'rendered')
  if type(result) == 'string' then
    ---@diagnostic disable-next-line: cast-type-mismatch
    ---@cast result string
    return result
  end
end

---@param rendered_diagnostic string
local function render_ansi_code_diagnostic(rendered_diagnostic)
  -- adopted from https://stackoverflow.com/questions/48948630/lua-ansi-escapes-pattern
  local lines =
    vim.split(rendered_diagnostic:gsub('[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]', ''), '\n', { trimempty = true })
  local float_preview_lines = vim.deepcopy(lines)
  table.insert(float_preview_lines, 1, '---')
  table.insert(float_preview_lines, 1, '1. Open in split')
  vim.schedule(function()
    local bufnr, winnr = vim.lsp.util.open_floating_preview(
      float_preview_lines,
      'plaintext',
      vim.tbl_extend('keep', config.tools.float_win_config, {
        focus_id = 'ra-render-diagnostic',
      })
    )
    vim.api.nvim_create_autocmd('WinEnter', {
      callback = function()
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(
            [[<c-\><c-n>]] .. '<cmd>lua vim.api.nvim_win_set_cursor(' .. winnr .. ',{1,0})<CR>',
            true,
            false,
            true
          ),
          'n',
          true
        )
      end,
      buffer = bufnr,
    })

    local chanid = vim.api.nvim_open_term(bufnr, {})
    vim.api.nvim_chan_send(chanid, vim.trim('1. Open in split\r\n' .. '---\r\n' .. rendered_diagnostic))

    _window_state.float_winnr = winnr
    set_close_keymaps(bufnr)
    set_split_open_keymap(bufnr, winnr, function()
      local chan_id = vim.api.nvim_open_term(_window_state.latest_scratch_buf_id, {})
      vim.api.nvim_chan_send(chan_id, vim.trim(rendered_diagnostic))
    end)
    if config.tools.float_win_config.auto_focus then
      vim.api.nvim_set_current_win(winnr)
      vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes(
          '<cmd>lua vim.api.nvim_set_current_win('
            .. winnr
            .. ')<CR>'
            .. [[<c-\><c-n>]]
            .. '<cmd>lua vim.api.nvim_win_set_cursor('
            .. winnr
            .. ',{1,0})<CR>',
          true,
          false,
          true
        ),
        'n',
        true
      )
    end
  end)
end

function M.render_diagnostic()
  local diagnostics = vim
    .iter(vim.diagnostic.get(0, {}))
    ---@param diagnostic vim.Diagnostic
    :filter(function(diagnostic)
      return get_rendered_diagnostic(diagnostic) ~= nil
    end)
    :totable()
  if #diagnostics == 0 then
    vim.notify('No renderable diagnostics found.', vim.log.levels.INFO)
    return
  end
  close_hover()
  local win_id = vim.api.nvim_get_current_win()
  local opts = {
    cursor_position = vim.api.nvim_win_get_cursor(win_id),
    wrap = true,
  }
  local rendered_diagnostic
  local diagnostic
  local pos_map = {}
  ---@type string
  local pos_id = '0'
  repeat
    diagnostic = vim.diagnostic.get_next(opts)
    pos_map[pos_id] = diagnostic
    if diagnostic == nil then
      break
    end
    rendered_diagnostic = get_rendered_diagnostic(diagnostic)
    local pos = { diagnostic.lnum, diagnostic.col }
    -- check if there is a rendered diagnostic at the same location
    if rendered_diagnostic == nil then
      local cursor_diagnostics = vim.tbl_filter(function(diag)
        return pos[1] == diag.lnum and pos[2] == diag.col
      end, diagnostics)
      if #cursor_diagnostics ~= 0 then
        diagnostic = cursor_diagnostics[1]
        rendered_diagnostic = get_rendered_diagnostic(diagnostic)
        break
      end
    end
    pos_id = vim.inspect(pos)
    -- diagnostics are (0,0)-indexed but cursors are (1,0)-indexed
    opts.cursor_position = { pos[1] + 1, pos[2] }
    local searched_all = pos_map[pos_id] ~= nil
  until diagnostic == nil or rendered_diagnostic ~= nil or searched_all
  if not rendered_diagnostic then
    -- No diagnostics found. Fall back to first result from filter,
    diagnostic = diagnostics[1]
    rendered_diagnostic = get_rendered_diagnostic(diagnostic)
    ---@cast rendered_diagnostic string
  end

  -- Save position in the window's jumplist
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(win_id, { diagnostic.lnum + 1, diagnostic.col })
  -- Open folds under the cursor
  vim.cmd('normal! zv')

  render_ansi_code_diagnostic(rendered_diagnostic)
end

---@return vim.Diagnostic[]
local function get_diagnostics_current_line()
  local win_id = vim.api.nvim_get_current_win()
  local cursor_position = vim.api.nvim_win_get_cursor(win_id)
  return vim.diagnostic.get(0, {
    lnum = cursor_position[1] - 1,
  })
end

---@return vim.Diagnostic[]
local function get_diagnostics_at_cursor()
  local win_id = vim.api.nvim_get_current_win()
  local cursor_position = vim.api.nvim_win_get_cursor(win_id)
  return vim.diagnostic.get(0, {
    pos = cursor_position,
  })
end

function M.render_diagnostic_current_line()
  -- get rendered diagnostics from current line
  ---@type string[]
  local rendered_diagnostics = vim
    .iter(get_diagnostics_current_line())
    ---@param diagnostic vim.Diagnostic
    :map(function(diagnostic)
      return get_rendered_diagnostic(diagnostic)
    end)
    :totable()

  -- if no renderable diagnostics on current line
  if #rendered_diagnostics == 0 then
    vim.notify('No renderable diagnostics found.', vim.log.levels.INFO)
    return
  end

  local rendered_diagnostic = rendered_diagnostics[1]
  render_ansi_code_diagnostic(rendered_diagnostic)
end

---@class rustaceanvim.diagnostic.RelatedInfo
---@field location lsp.Location
---@field message string

function M.related_diagnostics()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  ---@type lsp.Location[]
  local locations = vim
    .iter(get_diagnostics_at_cursor())
    ---@param diagnostic vim.Diagnostic
    :map(function(diagnostic)
      return vim.tbl_get(diagnostic, 'user_data', 'lsp', 'relatedInformation')
    end)
    :flatten()
    ---@param related_info rustaceanvim.diagnostic.RelatedInfo
    :map(function(related_info)
      return related_info.location
    end)
    :totable()
  if #locations == 0 then
    vim.notify('No related diagnostics found.', vim.log.levels.INFO)
    return
  end
  local quickfix_entries = vim.lsp.util.locations_to_items(locations, clients[1].offset_encoding)
  if #quickfix_entries == 1 then
    local item = quickfix_entries[1]
    ---@diagnostic disable-next-line: undefined-field
    local b = item.bufnr or vim.fn.bufadd(item.filename)
    -- Save position in jumplist
    vim.cmd.normal { "m'", bang = true }
    -- Push a new item into tagstack
    local tagstack = { { tagname = vim.fn.expand('<cword>'), from = vim.fn.getpos('.') } }
    local current_window_id = vim.api.nvim_get_current_win()
    vim.fn.settagstack(vim.fn.win_getid(current_window_id), { items = tagstack }, 't')
    vim.bo[b].buflisted = true
    local window_id = vim.fn.win_findbuf(b)[1] or current_window_id
    vim.api.nvim_win_set_buf(window_id, b)
    vim.api.nvim_win_set_cursor(window_id, { item.lnum, item.col - 1 })
    vim._with({ win = window_id }, function()
      -- Open folds under the cursor
      vim.cmd.normal { 'zv', bang = true }
    end)
  else
    vim.fn.setqflist({}, ' ', { title = 'related diagnostics', items = quickfix_entries })
    vim.cmd([[ botright copen ]])
  end
end

return M
