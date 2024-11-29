local M = {}

local compat = require('rustaceanvim.compat')

local function get_params()
  return {
    textDocument = vim.lsp.util.make_text_document_params(0),
  }
end

local function handler(_, result, ctx)
  if result == nil then
    return
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    compat.show_document(result, client.offset_encoding or 'utf-8')
  end
end

local rl = require('rustaceanvim.rust_analyzer')

--- Sends the request to rust-analyzer to get cargo.toml's location and open it
function M.open_cargo_toml()
  rl.buf_request(0, 'experimental/openCargoToml', get_params(), handler)
end

return M.open_cargo_toml
