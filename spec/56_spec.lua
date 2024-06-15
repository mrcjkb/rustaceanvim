local stub = require('luassert.stub')
local notify = stub(vim, 'notify')

describe('#56-non-regression: server.settings is table', function()
  vim.g.rustaceanvim = {
    server = {
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = true,
          check = {
            enable = true,
            command = 'clippy',
            features = 'all',
          },
          procMacro = {
            enable = true,
          },
        },
      },
    },
  }
  it('No errors or warning on config initialization', function()
    local ok, err = pcall(require, 'rustaceanvim.config.internal')
    assert(ok, 'Error on initialization: ' .. vim.inspect(err))
    assert.stub(notify).called_at_most(0)
  end)
end)
