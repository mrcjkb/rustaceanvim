vim.env.LAZY_STDPATH = '.repro'

-- Bootstrap lazy.nvim safely
local bootstrap = vim.fn.system('curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua')
local ok, lazy_boot = pcall(loadstring(bootstrap))
if ok then
  lazy_boot()
else
  error("Failed to bootstrap lazy.nvim: " .. tostring(lazy_boot))
end

require('lazy.minit').repro {
  spec = {
    {
      'mrcjkb/rustaceanvim',
      version = '^6',
      init = function()
        vim.g.rustaceanvim = {}
      end,
      lazy = false,
    },
  },
}
