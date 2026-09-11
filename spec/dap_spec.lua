---@diagnostic disable: undefined-field

local stub = require('luassert.stub')

describe('DAP configurations autoload', function()
  it('runs an autoloaded debug configuration', function()
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(bufnr, 'main.rs')
    vim.bo[bufnr].filetype = 'rust'
    vim.api.nvim_set_current_buf(bufnr)

    local rl = require('rustaceanvim.rust_analyzer')
    local buf_request = stub(rl, 'buf_request')
    buf_request.invokes(function(_, method, _, handler)
      if method == 'experimental/runnables' then
        handler(nil, {
          {
            args = {
              cargoArgs = { 'run', '--package', 'rustaceanvim-test', '--bin', 'rustaceanvim-test' },
              executableArgs = {},
            },
          },
        })
      end
    end)

    local rt_dap = require('rustaceanvim.dap')
    local dap_start = stub(rt_dap, 'start')
    dap_start.invokes(function(_, _, callback)
      callback { type = 'codelldb', request = 'launch', name = 'placeholder' }
    end)

    require('dap').configurations.rust = {}
    require('rustaceanvim.commands.debuggables').add_dap_debuggables()

    local dap = require('dap')
    local loaded = vim.wait(10000, function()
      return #dap.configurations.rust > 0
    end)
    assert.is_true(loaded)

    local run = stub(dap, 'run')
    dap.continue()
    local ran = vim.wait(10000, function()
      return #run.calls > 0
    end)
    run:revert()
    dap_start:revert()
    buf_request:revert()
    vim.api.nvim_buf_delete(bufnr, { force = true })
    assert.is_true(ran)
    assert.matches('build', run.calls[1].vals[1].name, 1, true)
  end)
end)
