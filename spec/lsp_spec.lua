describe('LSP client API', function()
  local FerrisConfig = require('ferris.config.internal')
  local Types = require('ferris.types.internal')
  local ra_bin = Types.evaluate(FerrisConfig.server.cmd)[1]
  if vim.fn.executable(ra_bin) ~= 0 then
    it('Can spin up rust-analyzer.', function()
      --- TODO: Figure out how to add tests for this
      print('TODO')
    end)
  end
end)
