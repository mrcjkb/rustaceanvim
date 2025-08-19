vim.env.LAZY_STDPATH = '.repro'
---@diagnostic disable-next-line: param-type-mismatch
load(vim.fn.system('curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua'))()

require('lazy.minit').repro {
  spec = {
    {
      'mrcjkb/rustaceanvim',
      version = '^6',
      init = function()
        -- Configure rustaceanvim here
        vim.g.rustaceanvim = {}
      end,
      lazy = false,
    },
  },
}
