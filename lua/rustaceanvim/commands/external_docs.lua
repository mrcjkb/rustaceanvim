local M = {}

local rl = require('rustaceanvim.rust_analyzer')

function M.open_external_docs()
  rl.buf_request(0, 'experimental/externalDocs', vim.lsp.util.make_position_params(), function(_, url)
    if url then
      local config = require('rustaceanvim.config.internal')
      config.tools.open_url(url)
    end
  end)
end

return M.open_external_docs
