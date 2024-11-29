local M = {}

function M.open_external_docs()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  ra.buf_request(
    0,
    'experimental/externalDocs',
    vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8'),
    function(_, url)
      if url then
        local config = require('rustaceanvim.config.internal')
        config.tools.open_url(url)
      end
    end
  )
end

return M.open_external_docs
