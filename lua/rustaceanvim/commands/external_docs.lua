local M = {}

function M.open_external_docs()
  local ra = require('rustaceanvim.rust_analyzer')
  local client = ra.find_active_rustaceanvim_client(0)
  if not client then
    return
  end
  ra.buf_request(
    0,
    'experimental/externalDocs',
    vim.lsp.util.make_position_params(0, client.offset_encoding or 'utf-8'),
    function(_, response)
      local url
      if response['local'] and vim.uv.fs_stat(vim.uri_to_fname(response['local'])) then
        url = response['local']
      else
        url = response.web
      end
      if url then
        local config = require('rustaceanvim.config.internal')
        config.tools.open_url(url)
      end
    end
  )
end

return M.open_external_docs
