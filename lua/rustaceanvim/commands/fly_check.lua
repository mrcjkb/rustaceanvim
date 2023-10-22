local M = {}

local rl = require('rustaceanvim.rust_analyzer')
function M.fly_check()
  local params = vim.lsp.util.make_text_document_params()
  rl.notify('rust-analyzer/runFlyCheck', params)
end

return M.fly_check
