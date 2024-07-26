vim.env.LAZY_STDPATH = '.repro'
load(vim.fn.system('curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua'))()

require('lazy.minit').repro {
  spec = {
    {
      'mrcjkb/rustaceanvim',
      version = '^5',
      init = function()
        -- Configure rustaceanvim here
        vim.g.rustaceanvim = {}
      end,
      lazy = false,
    },
  },
}
