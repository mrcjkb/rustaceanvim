local M = {}

local rl = require('rustaceanvim.rust_analyzer')

---@alias flyCheckCommand 'run' | 'clear' | 'cancel'

---@param cmd flyCheckCommand
function M.fly_check(cmd)
  local params = cmd == 'run' and vim.lsp.util.make_text_document_params() or {}
  rl.notify('rust-analyzer/' .. cmd .. 'Flycheck', params)
end

return M.fly_check
