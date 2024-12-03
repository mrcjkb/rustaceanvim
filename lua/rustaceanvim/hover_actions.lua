local config = require('rustaceanvim.config.internal')
local lsp_util = vim.lsp.util

local M = {}

---@class rustaceanvim.hover_actions.State
local _state = {
  ---@type integer
  winnr = nil,
  ---@type unknown
  commands = nil,
}

local function close_hover()
  local ui = require('rustaceanvim.ui')
  ui.close_win(_state.winnr)
end

local function execute_rust_analyzer_command(action, ctx)
  local fn = vim.lsp.commands[action.command]
  if fn then
    fn(action, ctx)
  end
end

-- run the command under the cursor, if the thing under the cursor is not the
-- command then do nothing
---@param ctx table
---@param line integer
local function run_command(ctx, line)
  if line > #_state.commands then
    return
  end

  local action = _state.commands[line]

  close_hover()
  execute_rust_analyzer_command(action, ctx)
end

---@return string[]
local function parse_commands()
  local prompt = {}

  for i, value in ipairs(_state.commands) do
    if value.command == 'rust-analyzer.gotoLocation' then
      table.insert(prompt, string.format('%d. Go to %s (%s)', i, value.title, value.tooltip))
    elseif value.command == 'rust-analyzer.showReferences' then
      table.insert(prompt, string.format('%d. %s', i, 'Go to ' .. value.title))
    else
      table.insert(prompt, string.format('%d. %s', i, value.title))
    end
  end

  return prompt
end

---@param ctx lsp.HandlerContext
function M.handler(_, result, ctx)
  if not (result and result.contents) then
    -- return { 'No information available' }
    return
  end

  local markdown_lines = lsp_util.convert_input_to_markdown_lines(result.contents, {})
  if result.actions then
    _state.commands = result.actions[1].commands
    local prompt = parse_commands()
    local l = {}

    for _, value in ipairs(prompt) do
      table.insert(l, value)
    end
    table.insert(l, '---')

    markdown_lines = vim.list_extend(l, markdown_lines)
  end

  if vim.tbl_isempty(markdown_lines) then
    -- return { 'No information available' }
    return
  end

  -- NOTE: This is for backward compatibility
  local win_opt = vim.tbl_deep_extend('force', config.tools.float_win_config, config.tools.hover_actions)

  local bufnr, winnr = lsp_util.open_floating_preview(
    markdown_lines,
    'markdown',
    vim.tbl_extend('keep', win_opt, {
      focusable = true,
      focus_id = 'rust-analyzer-hover-actions',
      close_events = { 'CursorMoved', 'BufHidden', 'InsertCharPre' },
    })
  )

  if win_opt.auto_focus then
    vim.api.nvim_set_current_win(winnr)
  end

  if _state.winnr ~= nil then
    return
  end

  -- update the window number here so that we can map escape to close even
  -- when there are no actions, update the rest of the state later
  _state.winnr = winnr
  vim.keymap.set('n', 'q', close_hover, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<Esc>', close_hover, { buffer = bufnr, noremap = true, silent = true })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      _state.winnr = nil
    end,
  })

  --- stop here if there are no possible actions
  if result.actions == nil then
    return
  end

  -- makes more sense in a dropdown-ish ui
  vim.wo[winnr].cursorline = true

  -- explicitly disable signcolumn
  vim.wo[winnr].signcolumn = 'no'

  -- run the command under the cursor
  vim.keymap.set('n', '<CR>', function()
    local line = vim.api.nvim_win_get_cursor(winnr)[1]
    run_command(ctx, line)
  end, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set('n', '<Plug>RustHoverAction', function()
    local line = math.max(vim.v.count, 1)
    run_command(ctx, line)
  end, { buffer = vim.api.nvim_get_current_buf(), noremap = true, silent = true })
end

--- Sends the request to rust-analyzer to get hover actions and handle it
function M.hover_actions()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = lsp_util.make_position_params(0, clients[1].offset_encoding or 'utf-8')
  ra.buf_request(0, 'textDocument/hover', params, M.handler)
end

return M
