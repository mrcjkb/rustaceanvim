local uv = vim.uv or vim.loop
-- load RustAnalyzer command
require('rustaceanvim.lsp')

local stub = require('luassert.stub')
describe('LSP client API', function()
  local RustaceanConfig = require('rustaceanvim.config.internal')
  local Types = require('rustaceanvim.types.internal')
  local ra_bin = Types.evaluate(RustaceanConfig.server.cmd)[1]
  if vim.fn.executable(ra_bin) ~= 0 then
    it('Can spin up rust-analyzer.', function()
      local lsp_start = stub(vim.lsp, 'start')
      vim.cmd.e('test.rs')
      vim.cmd.RustAnalyzer('start')
      -- TODO: Use something less flaky, e.g. a timeout
      uv.sleep(5000)
      assert.stub(lsp_start).was_called()
    end)
  end
end)
