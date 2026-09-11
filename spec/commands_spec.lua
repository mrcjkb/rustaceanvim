---@diagnostic disable: undefined-field

local stub = require('luassert.stub')

local function has_label(labels, pattern)
  for _, label in ipairs(labels or {}) do
    if label:lower():find(pattern) then
      return true
    end
  end
  return false
end

local timeout_ms = 60000

describe('RustLsp commands', function()
  local root_dir = vim.fn.tempname()
  local main_rs = {
    'fn main() {',
    '    println!("hello world");',
    '    second();',
    '}',
    '',
    'fn second() {',
    '    let unused = 42;',
    '    println!("second");',
    '}',
    '',
    'fn add(a: i32, b: i32) -> i32 {',
    '    a + b',
    '}',
    '',
    '#[cfg(test)]',
    'mod tests {',
    '    #[test]',
    '    fn test_main() {',
    '        assert_eq!(1 + 1, 2);',
    '    }',
    '',
    '    #[test]',
    '    fn test_add() {',
    '        assert_eq!(super::add(1, 2), 3);',
    '    }',
    '}',
    '',
    'struct Point {',
    '    x: i32,',
    '    y: i32,',
    '}',
    '',
    'fn make_point() {',
    '    let p = Point { x: 1, y: 2 };',
    '    let _ = p;',
    '}',
    '',
    'fn join_lines_fixture() {',
    '    let sum = 1',
    '        + 2;',
    '}',
    '',
    'fn call_second() {',
    '    second();',
    '}',
    '',
    'mod foo;',
  }
  local foo_rs = {
    'pub fn foo() -> i32 {',
    '    42',
    '}',
  }
  vim.fn.mkdir(vim.fs.joinpath(root_dir, 'src'), 'p')
  vim.fn.writefile({
    '[package]',
    'name = "rustaceanvim-test"',
    'version = "0.1.0"',
    'edition = "2021"',
  }, vim.fs.joinpath(root_dir, 'Cargo.toml'))
  vim.fn.writefile(main_rs, vim.fs.joinpath(root_dir, 'src', 'main.rs'))
  vim.fn.writefile(foo_rs, vim.fs.joinpath(root_dir, 'src', 'foo.rs'))

  local initialized = false
  local captured = nil
  local captured_test
  ---@type string | nil
  local captured_url
  vim.g.rustaceanvim = {
    server = {
      root_dir = root_dir,
    },
    tools = {
      on_initialized = function()
        initialized = true
      end,
      enable_nextest = false,
      open_url = function(url)
        captured_url = url
      end,
      code_actions = {
        ui_select_fallback = true,
      },
      executor = {
        execute_command = function(command, args, cwd, opts)
          captured = { command = command, args = args, cwd = cwd, opts = opts }
        end,
      },
      test_executor = {
        execute_command = function(command, args, cwd, opts)
          captured_test = { command = command, args = args, cwd = cwd, opts = opts }
        end,
      },
    },
  }

  local lsp = require('rustaceanvim.lsp')
  local ra = require('rustaceanvim.rust_analyzer')
  local bufnr

  setup(function()
    bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(bufnr, vim.fs.joinpath(root_dir, 'src', 'main.rs'))
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
    vim.bo[bufnr].filetype = 'rust'
    vim.api.nvim_set_current_buf(bufnr)
    vim.cmd.runtime('ftplugin/rust.lua')
    lsp.start(bufnr)
    assert(
      vim.wait(timeout_ms, function()
        return #ra.get_active_rustaceanvim_clients(bufnr) > 0
      end),
      'failed to start the rust-analyzer LSP client'
    )
    assert(
      vim.wait(timeout_ms, function()
        return initialized
      end),
      'rust-analyzer did not finish initializing the workspace'
    )
  end)

  teardown(function()
    for _, client in ipairs(ra.get_active_rustaceanvim_clients(bufnr)) do
      client:stop()
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)

  it('runnables opens a prompt with the available targets', function()
    vim.api.nvim_set_current_buf(bufnr)
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('runnables')
    local options
    local called = vim.wait(timeout_ms, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called)
    assert.is_true(has_label(options, 'run'))
    assert.is_true(has_label(options, 'test'))
  end)

  it('selecting a runnable runs the target', function()
    vim.api.nvim_set_current_buf(bufnr)
    captured = nil
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('runnables')
    local options, on_choice
    local called = vim.wait(timeout_ms, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        on_choice = select.calls[1].vals[3]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called)
    local run_index
    for i, label in ipairs(options) do
      if label:lower():find('run') then
        run_index = i
        break
      end
    end
    assert.is_not_nil(run_index)
    on_choice(nil, run_index)
    assert.is_not_nil(captured)
    ---@diagnostic disable-next-line: need-check-nil
    assert.are.same('cargo', captured.command)
    ---@diagnostic disable-next-line: need-check-nil
    assert.are.same('run', captured.args[1])
  end)

  it('run executes the target at the cursor position', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    captured = nil
    vim.cmd.RustLsp('run')
    assert(
      vim.wait(timeout_ms, function()
        return captured ~= nil
      end),
      'executor was not called'
    )
    assert(captured)
    assert.are.same('cargo', captured.command)
    assert.are.same('run', captured.args[1])
  end)

  it('testables lists and runs test targets', function()
    vim.api.nvim_set_current_buf(bufnr)
    captured_test = {}
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('testables')
    local options, on_choice
    local called = vim.wait(timeout_ms, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        on_choice = select.calls[1].vals[3]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called)
    assert.is_true(has_label(options, 'test'))
    assert.is_false(has_label(options, 'run'))
    on_choice(nil, 1)
    assert.is_not_nil(captured_test)
    assert.are.same('cargo', captured_test.command)
    assert.are.same('test', captured_test.args[1])
  end)

  it('expandMacro expands the macro at the cursor position', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
    local ui = require('rustaceanvim.ui')
    local split = stub(ui, 'split')
    local resize = stub(ui, 'resize')
    vim.cmd.RustLsp('expandMacro')
    local expansion
    local rendered = vim.wait(timeout_ms, function()
      if #split.calls > 0 then
        expansion = table.concat(vim.api.nvim_buf_get_lines(split.calls[1].vals[2], 0, -1, false), '\n')
        return true
      end
      return false
    end)
    split:revert()
    resize:revert()
    assert.is_true(rendered)
    assert.matches('hello world', expansion, 1, true)
  end)

  it('moveItem moves the item up', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 6, 0 })
    vim.cmd.RustLsp { 'moveItem', 'up' }
    local moved = vim.wait(timeout_ms, function()
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
      return first_line:find('fn second', 1, true) ~= nil
    end)
    assert.is_true(moved)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
  end)

  it('codeAction applies the selected code action', function()
    vim.api.nvim_set_current_buf(bufnr)
    local target
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      local col = line:find('unused', 1, true)
      if col then
        target = { i, col - 1 }
        break
      end
    end
    assert(target, 'expected to find "unused" in the buffer')
    vim.api.nvim_win_set_cursor(0, target)
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('codeAction')
    local options, on_choice
    local called = vim.wait(timeout_ms, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        on_choice = select.calls[1].vals[3]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called)
    assert.is_true(#options > 0)
    local type_index
    for i, item in ipairs(options) do
      if item.action.title:lower():find('explicit type') then
        type_index = i
        break
      end
    end
    assert.is_not_nil(type_index)
    on_choice(options[type_index], type_index)
    local applied = vim.wait(timeout_ms, function()
      local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
      return content:find(': i32', 1, true) ~= nil
    end)
    assert.is_true(applied)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
  end)

  it('hover actions executes a hover action', function()
    vim.api.nvim_set_current_buf(bufnr)
    local target
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      local let_pos = line:find('let p =', 1, true)
      if let_pos then
        target = { i, let_pos + 3 }
        break
      end
    end
    assert(target, 'expected to find "let p =" in the buffer')
    vim.api.nvim_win_set_cursor(0, target)
    local before_wins = vim.api.nvim_list_wins()
    vim.cmd.RustLsp { 'hover', 'actions' }
    local preview_winnr
    local opened = vim.wait(timeout_ms, function()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if not vim.tbl_contains(before_wins, w) then
          preview_winnr = w
          return true
        end
      end
      return false
    end)
    assert.is_true(opened)
    local preview_buf = vim.api.nvim_win_get_buf(preview_winnr)
    local goto_line
    for i, line in ipairs(vim.api.nvim_buf_get_lines(preview_buf, 0, -1, false)) do
      if line:find('Go to', 1, true) then
        goto_line = i
        break
      end
    end
    assert.is_not_nil(goto_line)
    vim.api.nvim_set_current_win(preview_winnr)
    vim.api.nvim_win_set_cursor(preview_winnr, { goto_line, 0 })
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'x', false)
    local jumped = vim.wait(timeout_ms, function()
      local cur = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_buf_get_lines(bufnr, cur[1] - 1, cur[1], false)[1]
      return line ~= nil and line:find('struct Point', 1, true) ~= nil
    end)
    assert.is_true(jumped)
  end)

  it('hover range evaluates the selected expression', function()
    vim.api.nvim_set_current_buf(bufnr)
    local expr_line, expr_col
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      local pos = line:find('Point { x: 1', 1, true)
      if pos then
        expr_line = i
        expr_col = pos
        break
      end
    end
    assert(expr_line, 'expected to find "Point { x: 1" in the buffer')
    vim.fn.setpos("'v", { 0, expr_line, expr_col - 1, 0 })
    vim.api.nvim_win_set_cursor(0, { expr_line, expr_col + 18 })
    local before_wins = vim.api.nvim_list_wins()
    vim.cmd.RustLsp { 'hover', 'range' }
    local preview_winnr
    local opened = vim.wait(timeout_ms, function()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if not vim.tbl_contains(before_wins, w) then
          preview_winnr = w
          return true
        end
      end
      return false
    end)
    assert.is_true(opened)
    local content =
      table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(preview_winnr), 0, -1, false), '\n')
    assert.matches('Point', content, 1, true)
  end)

  it('explainError explains the error at the cursor', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.diagnostic.set(vim.api.nvim_create_namespace('rustaceanvim-test'), bufnr, {
      {
        lnum = 0,
        col = 0,
        severity = vim.diagnostic.severity.ERROR,
        source = 'rustc',
        code = 'E0308',
        message = 'mismatched types',
      },
    })
    local before_wins = vim.api.nvim_list_wins()
    vim.cmd.RustLsp { 'explainError', 'current' }
    local preview_winnr
    local opened = vim.wait(timeout_ms, function()
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if not vim.tbl_contains(before_wins, w) then
          preview_winnr = w
          return true
        end
      end
      return false
    end)
    assert.is_true(opened)
    local content =
      table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(preview_winnr), 0, -1, false), '\n')
    assert.matches('did not match', content, 1, true)
  end)

  it('renderDiagnostic renders the diagnostic at the cursor', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.diagnostic.set(vim.api.nvim_create_namespace('rustaceanvim-test'), bufnr, {
      {
        lnum = 0,
        col = 0,
        severity = vim.diagnostic.severity.WARN,
        source = 'rustc',
        code = 'unused_variables',
        message = 'unused variable',
        user_data = {
          lsp = {
            data = {
              rendered = 'warning: unused variable: `x`',
            },
          },
        },
      },
    })
    local contents
    local preview_buf = vim.api.nvim_create_buf(false, true)
    local preview = stub(vim.lsp.util, 'open_floating_preview')
    preview.invokes(function(lines)
      contents = lines
      return preview_buf, 0
    end)
    vim.cmd.RustLsp { 'renderDiagnostic', 'current' }
    local called = vim.wait(timeout_ms, function()
      return contents ~= nil
    end)
    preview:revert()
    vim.api.nvim_buf_delete(preview_buf, { force = true })
    assert.is_true(called)
    assert.matches('unused variable', table.concat(contents, '\n'), 1, true)
  end)

  it('relatedDiagnostics jumps to the related diagnostic', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.diagnostic.set(vim.api.nvim_create_namespace('rustaceanvim-test'), bufnr, {
      {
        lnum = 0,
        col = 0,
        severity = vim.diagnostic.severity.WARN,
        source = 'rustc',
        code = 'unused_variables',
        message = 'unused variable',
        user_data = {
          lsp = {
            relatedInformation = {
              {
                location = {
                  uri = vim.uri_from_bufnr(bufnr),
                  range = {
                    start = { line = 5, character = 0 },
                    ['end'] = { line = 5, character = 0 },
                  },
                },
                message = 'related location',
              },
            },
          },
        },
      },
    })
    vim.cmd.RustLsp('relatedDiagnostics')
    local jumped = vim.wait(timeout_ms, function()
      local cur = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_buf_get_lines(bufnr, cur[1] - 1, cur[1], false)[1]
      return line ~= nil and line:find('fn second', 1, true) ~= nil
    end)
    assert.is_true(jumped)
  end)

  it('relatedTests jumps to the related test', function()
    vim.api.nvim_set_current_buf(bufnr)
    local add_line
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      if line:find('fn add', 1, true) then
        add_line = i
        break
      end
    end
    assert(add_line, 'expected to find "fn add" in the buffer')
    vim.api.nvim_win_set_cursor(0, { add_line, 3 })
    vim.cmd.RustLsp('relatedTests')
    local jumped = vim.wait(timeout_ms, function()
      local cur = vim.api.nvim_win_get_cursor(0)
      local line = vim.api.nvim_buf_get_lines(bufnr, cur[1] - 1, cur[1], false)[1]
      return line ~= nil and line:find('fn test_add', 1, true) ~= nil
    end)
    assert.is_true(jumped)
  end)

  it('openCargo opens the Cargo.toml', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.cmd.RustLsp('openCargo')
    local opened = vim.wait(timeout_ms, function()
      return vim.api.nvim_buf_get_name(0):find('Cargo.toml', 1, true) ~= nil
    end)
    assert.is_true(opened)
  end)

  it('openDocs opens the docs.rs documentation', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
    captured_url = nil
    vim.cmd.RustLsp('openDocs')
    local opened = vim.wait(timeout_ms, function()
      return captured_url ~= nil
    end)
    assert.is_true(opened)
    ---@cast captured_url string
    assert.matches('https://', captured_url, 1, true)
  end)

  it('parentModule jumps to the parent module', function()
    local foo_buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(foo_buf, vim.fs.joinpath(root_dir, 'src', 'foo.rs'))
    vim.api.nvim_buf_set_lines(foo_buf, 0, -1, false, foo_rs)
    vim.bo[foo_buf].filetype = 'rust'
    vim.api.nvim_set_current_buf(foo_buf)
    lsp.start(foo_buf)
    local attached = vim.wait(timeout_ms, function()
      return #ra.get_active_rustaceanvim_clients(foo_buf) > 0
    end)
    assert.is_true(attached)
    vim.cmd.RustLsp('parentModule')
    local jumped = vim.wait(timeout_ms, function()
      return vim.api.nvim_buf_get_name(0):find('main.rs', 1, true) ~= nil
    end)
    assert.is_true(jumped)
    vim.api.nvim_buf_delete(foo_buf, { force = true })
  end)

  it('workspaceSymbol searches for symbols', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.cmd.RustLsp { 'workspaceSymbol', 'add' }
    local searched = vim.wait(timeout_ms, function()
      for _, item in ipairs(vim.fn.getqflist()) do
        if type(item.text) == 'string' and item.text:find('add', 1, true) then
          return true
        end
      end
      return false
    end)
    assert.is_true(searched)
  end)

  it('joinLines joins the lines', function()
    vim.api.nvim_set_current_buf(bufnr)
    local join_line
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      if line:find('let sum', 1, true) then
        join_line = i
        break
      end
    end
    assert(join_line, 'expected to find "let sum" in the buffer')
    vim.api.nvim_win_set_cursor(0, { join_line, 0 })
    vim.cmd.RustLsp('joinLines')
    local joined = vim.wait(timeout_ms, function()
      local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
      return content:find('let sum = 1 + 2', 1, true) ~= nil
    end)
    assert.is_true(joined)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
  end)

  it('ssr performs a structural search replace', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.lsp.util.buf_versions[bufnr] = 0
    vim.cmd.RustLsp { 'ssr', 'second() ==>> add(1, 2)' }
    local replaced = vim.wait(timeout_ms, function()
      local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
      return content:find('add(1, 2);', 1, true) ~= nil
    end)
    assert.is_true(replaced)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
  end)

  it('ssr replaces within the visual selection', function()
    vim.api.nvim_set_current_buf(bufnr)
    local selected_line, unselected_line
    for i, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
      if line:find('second();', 1, true) then
        if selected_line == nil then
          selected_line = i
        else
          unselected_line = i
          break
        end
      end
    end
    assert(selected_line, 'expected to find "second();" in the buffer')
    assert(unselected_line, 'expected a second "second();" in the buffer')
    vim.api.nvim_buf_set_mark(bufnr, '<', selected_line, 4, {})
    vim.api.nvim_buf_set_mark(bufnr, '>', selected_line, 12, {})
    vim.lsp.util.buf_versions[bufnr] = 0
    vim.cmd("'<,'>RustLsp ssr second() ==>> add(1, 2)")
    local replaced = vim.wait(timeout_ms, function()
      local selected = vim.api.nvim_buf_get_lines(bufnr, selected_line - 1, selected_line, false)[1]
      local unselected = vim.api.nvim_buf_get_lines(bufnr, unselected_line - 1, unselected_line, false)[1]
      return selected:find('add(1, 2)', 1, true) ~= nil and unselected:find('second();', 1, true) ~= nil
    end)
    assert.is_true(replaced)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, main_rs)
  end)

  it('syntaxTree shows the syntax tree', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    local ui = require('rustaceanvim.ui')
    local split = stub(ui, 'split')
    local resize = stub(ui, 'resize')
    vim.cmd.RustLsp('syntaxTree')
    local syntax_buf
    local opened = vim.wait(timeout_ms, function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(b):find('syntax.rust', 1, true) then
          syntax_buf = b
          return true
        end
      end
      return false
    end)
    split:revert()
    resize:revert()
    assert.is_true(opened)
    local content = table.concat(vim.api.nvim_buf_get_lines(syntax_buf, 0, -1, false), '\n')
    assert.matches('SOURCE_FILE', content, 1, true)
  end)

  it('view mir shows the MIR', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
    local ui = require('rustaceanvim.ui')
    local split = stub(ui, 'split')
    local resize = stub(ui, 'resize')
    vim.cmd.RustLsp { 'view', 'mir' }
    local mir
    local rendered = vim.wait(timeout_ms, function()
      if #split.calls > 0 then
        mir = table.concat(vim.api.nvim_buf_get_lines(split.calls[1].vals[2], 0, -1, false), '\n')
        return true
      end
      return false
    end)
    split:revert()
    resize:revert()
    assert.is_true(rendered)
    assert.matches('fn main', mir, 1, true)
  end)

  it('logFile opens the rust-analyzer log file', function()
    vim.api.nvim_set_current_buf(bufnr)
    local config = require('rustaceanvim.config.internal')
    local logfile = config.server.logfile
    vim.cmd.RustLsp('logFile')
    assert.equals(vim.api.nvim_buf_get_name(0), logfile)
  end)
end)
