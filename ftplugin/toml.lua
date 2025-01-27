if vim.fn.has('nvim-0.10') ~= 1 then
  vim.notify_once('rustaceanvim requires Neovim 0.10 or above', vim.log.levels.ERROR)
  return
end

local fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':t')
if fname ~= 'Cargo.toml' then
  return
end

local config = require('rustaceanvim.config.internal')
local ra = require('rustaceanvim.rust_analyzer')
if config.tools.reload_workspace_from_cargo_toml then
  local group = vim.api.nvim_create_augroup('RustaceanCargoReloadWorkspace', { clear = false })
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_clear_autocmds {
    buffer = bufnr,
    group = group,
  }
  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = vim.api.nvim_get_current_buf(),
    group = group,
    callback = function()
      if #ra.get_active_rustaceanvim_clients(nil) > 0 then
        vim.cmd.RustLsp { 'reloadWorkspace', mods = { silent = true } }
      end
    end,
  })
end
