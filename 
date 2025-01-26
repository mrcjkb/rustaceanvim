local M = {}

local compat = require('rustaceanvim.compat')

local function handler(_, result, ctx)
  if result == nil or vim.tbl_isempty(result) then
    vim.notify("Can't find parent module.", vim.log.levels.ERROR)
    return
  end

  local location = result

  if vim.islist(result) then
    location = result[1]
  end

  local client = vim.lsp.get_client_by_id(ctx.client_id)
  if client then
    compat.show_document(location, client.offset_encoding or 'utf-8')
  end
end

--- Sends the request to rust-analyzer to get the parent modules location and open it
function M.parent_module()
  local ra = require('rustaceanvim.rust_analyzer')
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding or 'utf-8')
  ra.buf_request(0, 'experimental/parentModule', params, handler)
end

return M.parent_module
