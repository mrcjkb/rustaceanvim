local stub = require('luassert.stub')
describe('LSP client API', function()
  local root_dir = vim.fn.tempname()
  vim.fn.mkdir(vim.fs.joinpath(root_dir, 'src'), 'p')
  vim.fn.writefile({
    '[package]',
    'name = "rustaceanvim-test"',
    'version = "0.1.0"',
    'edition = "2021"',
  }, vim.fs.joinpath(root_dir, 'Cargo.toml'))
  vim.fn.writefile({ 'pub fn test() {}' }, vim.fs.joinpath(root_dir, 'src', 'lib.rs'))
  vim.g.rustaceanvim = {
    server = {
      root_dir = root_dir,
    },
  }
  local notify_once = stub(vim, 'notify_once')
  local notify = stub(vim, 'notify')
  local deprecate = stub(vim, 'deprecate')
  local lsp = require('rustaceanvim.lsp')
  local RustaceanConfig = require('rustaceanvim.config.internal')
  local Types = require('rustaceanvim.types.internal')
  local ra_bin = Types.evaluate(RustaceanConfig.server.cmd)[1]
  it("doesn't trigger notifications", function()
    if not pcall(assert.stub(notify_once).called, 0) then
      assert.stub(notify_once).called_with(nil)
    end
    if not pcall(assert.stub(notify).called, 0) then
      assert.stub(notify).called_with(nil)
    end
  end)
  it("doesn't trigger deprecation warnings", function()
    if not pcall(assert.stub(deprecate).called, 0) then
      assert.stub(deprecate).called_with(nil)
    end
  end)
  it('can spin up rust-analyzer.', function()
    assert(vim.fn.executable(ra_bin) == 1, ra_bin .. ' is not executable')
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(bufnr, 'test.rs')
    vim.bo[bufnr].filetype = 'rust'
    vim.api.nvim_set_current_buf(bufnr)
    vim.lsp.log.set_level(vim.lsp.log.levels.DEBUG)
    lsp.start(bufnr)
    local ra = require('rustaceanvim.rust_analyzer')
    local success = vim.wait(30000, function()
      return #ra.get_active_rustaceanvim_clients(bufnr) > 0
    end)
    if not success then
      local log_file = vim.lsp.log.get_filename()
      local log = vim.uv.fs_stat(log_file) and table.concat(vim.fn.readfile(log_file), '\n') or ''
      error('failed to start the rust-analyzer LSP client\n\n' .. log)
    end
    for _, client in ipairs(ra.get_active_rustaceanvim_clients(bufnr)) do
      client:stop()
    end
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end)
end)
