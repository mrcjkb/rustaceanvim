local M = {}

local rl = require('rustaceanvim.rust_analyzer')

local function make_flycheck_params()
  return { textDocument = vim.lsp.util.make_text_document_params() }
end

---@alias rustaceanvim.flyCheckCommand 'run' | 'clear' | 'cancel'

---@param cmd rustaceanvim.flyCheckCommand
function M.fly_check(cmd)
  local params = cmd == 'run' and make_flycheck_params() or nil
  rl.notify('rust-analyzer/' .. cmd .. 'Flycheck', params)
end

return M.fly_check
