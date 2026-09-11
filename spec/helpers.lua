local M = {}

M.timeout_ms = 10000

M.main_rs = {
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

M.foo_rs = {
  'pub fn foo() -> i32 {',
  '    42',
  '}',
}

local initialized = false

function M.setup_project()
  local root_dir = vim.fn.tempname()
  vim.fn.mkdir(vim.fs.joinpath(root_dir, 'src'), 'p')
  vim.fn.writefile({
    '[package]',
    'name = "rustaceanvim-test"',
    'version = "0.1.0"',
    'edition = "2021"',
  }, vim.fs.joinpath(root_dir, 'Cargo.toml'))
  vim.fn.writefile(M.main_rs, vim.fs.joinpath(root_dir, 'src', 'main.rs'))
  vim.fn.writefile(M.foo_rs, vim.fs.joinpath(root_dir, 'src', 'foo.rs'))
  return root_dir
end

function M.configure(root_dir, config)
  initialized = false
  vim.g.rustaceanvim = vim.tbl_deep_extend('force', {
    server = { root_dir = root_dir },
    tools = {
      on_initialized = function()
        initialized = true
      end,
    },
  }, config or {})
end

function M.start_client(root_dir)
  local bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(bufnr, vim.fs.joinpath(root_dir, 'src', 'main.rs'))
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, M.main_rs)
  vim.bo[bufnr].filetype = 'rust'
  vim.api.nvim_set_current_buf(bufnr)
  vim.cmd.runtime('ftplugin/rust.lua')

  local lsp = require('rustaceanvim.lsp')
  local ra = require('rustaceanvim.rust_analyzer')
  lsp.start(bufnr)
  assert(
    vim.wait(M.timeout_ms, function()
      return #ra.get_active_rustaceanvim_clients(bufnr) > 0
    end),
    'failed to start the rust-analyzer LSP client'
  )
  assert(
    vim.wait(M.timeout_ms, function()
      return initialized
    end),
    'rust-analyzer did not finish initializing the workspace'
  )
  return bufnr
end

function M.stop_client(bufnr)
  local ra = require('rustaceanvim.rust_analyzer')
  for _, client in ipairs(ra.get_active_rustaceanvim_clients(bufnr)) do
    client:stop()
  end
  vim.api.nvim_buf_delete(bufnr, { force = true })
end

function M.sync_buf(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    return
  end
  local done = false
  clients[1]:request('textDocument/documentSymbol', { textDocument = { uri = vim.uri_from_bufnr(bufnr) } }, function()
    done = true
  end, bufnr)
  vim.wait(M.timeout_ms, function()
    return done
  end)
end

return M
