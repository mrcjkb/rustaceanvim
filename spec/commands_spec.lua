local stub = require('luassert.stub')

local function has_label(labels, pattern)
  for _, label in ipairs(labels or {}) do
    if label:lower():find(pattern) then
      return true
    end
  end
  return false
end

describe('RustLsp commands', function()
  local root_dir = vim.fn.tempname()
  local main_rs = {
    'fn main() {',
    '    println!("hello world");',
    '}',
    '',
    '#[cfg(test)]',
    'mod tests {',
    '    #[test]',
    '    fn test_main() {',
    '        assert_eq!(1 + 1, 2);',
    '    }',
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

  local initialized = false
  local captured
  local captured_test
  vim.g.rustaceanvim = {
    server = {
      root_dir = root_dir,
    },
    tools = {
      on_initialized = function()
        initialized = true
      end,
      enable_nextest = false,
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
    lsp.start(bufnr)
    assert(
      vim.wait(30000, function()
        return #ra.get_active_rustaceanvim_clients(bufnr) > 0
      end),
      'failed to start the rust-analyzer LSP client'
    )
    assert(
      vim.wait(30000, function()
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
    local called = vim.wait(30000, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called, 'vim.ui.select was not called')
    assert.is_true(has_label(options, 'run'), 'expected a run target in: ' .. vim.inspect(options))
    assert.is_true(has_label(options, 'test'), 'expected a test target in: ' .. vim.inspect(options))
  end)

  it('selecting a runnable runs the target', function()
    vim.api.nvim_set_current_buf(bufnr)
    captured = nil
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('runnables')
    local options, on_choice
    local called = vim.wait(30000, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        on_choice = select.calls[1].vals[3]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called, 'vim.ui.select was not called')
    local run_index
    for i, label in ipairs(options) do
      if label:lower():find('run') then
        run_index = i
        break
      end
    end
    assert.is_not_nil(run_index, 'no run target in: ' .. vim.inspect(options))
    on_choice(nil, run_index)
    assert.is_not_nil(captured, 'executor was not called')
    assert.are.same('cargo', captured.command)
    assert.are.same('run', captured.args[1])
  end)

  it('run executes the target at the cursor position', function()
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    captured = nil
    vim.cmd.RustLsp('run')
    assert(
      vim.wait(30000, function()
        return captured ~= nil
      end),
      'executor was not called'
    )
    assert.are.same('cargo', captured.command)
    assert.are.same('run', captured.args[1])
  end)

  it('testables lists and runs test targets', function()
    vim.api.nvim_set_current_buf(bufnr)
    captured_test = nil
    local select = stub(vim.ui, 'select')
    vim.cmd.RustLsp('testables')
    local options, on_choice
    local called = vim.wait(30000, function()
      if #select.calls > 0 then
        options = select.calls[1].vals[1]
        on_choice = select.calls[1].vals[3]
        return true
      end
      return false
    end)
    select:revert()
    assert.is_true(called, 'vim.ui.select was not called')
    assert.is_true(has_label(options, 'test'), 'expected a test target in: ' .. vim.inspect(options))
    assert.is_false(has_label(options, 'run'), 'expected no run target in: ' .. vim.inspect(options))
    on_choice(nil, 1)
    assert.is_not_nil(captured_test, 'test executor was not called')
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
    local rendered = vim.wait(30000, function()
      if #split.calls > 0 then
        expansion = table.concat(vim.api.nvim_buf_get_lines(split.calls[1].vals[2], 0, -1, false), '\n')
        return true
      end
      return false
    end)
    split:revert()
    resize:revert()
    assert.is_true(rendered, 'expected the macro to expand')
    assert.matches('hello world', expansion, 1, true)
  end)
end)
