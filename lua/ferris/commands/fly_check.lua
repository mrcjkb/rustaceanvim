local M = {}

function M.fly_check()
  local params = vim.lsp.util.make_text_document_params()
  for _, client in ipairs(vim.lsp.get_clients { name = 'rust-analyzer' }) do
    client.notify('rust-analyzer/runFlyCheck', params)
  end
end

return M.fly_check
