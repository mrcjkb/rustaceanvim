local M = {}

---@param c string A single character
---@return string The hex representation
local char_to_hex = function(c)
  return string.format('%%%02X', c:byte())
end

---Encode a URL so it can be opened in a browser
---@param url string
---@return string encoded_url
local function urlencode(url)
  url = url:gsub('\n', '\r\n')
  url = url:gsub('([^%w ])', char_to_hex)
  url = url:gsub(' ', '+')
  return url
end

local rl = require('ferris.rust_analyzer')

function M.open_external_docs()
  rl.buf_request(0, 'experimental/externalDocs', vim.lsp.util.make_position_params(), function(_, url)
    if url then
      vim.fn['netrw#BrowseX'](urlencode(url), 0)
    end
  end)
end

return M.open_external_docs
