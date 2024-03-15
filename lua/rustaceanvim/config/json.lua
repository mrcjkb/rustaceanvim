local M = {}

local function tbl_set(tbl, keys, value)
  local next = table.remove(keys, 1)
  if #keys > 0 then
    tbl[next] = tbl[next] or {}
    tbl_set(tbl[next], keys, value)
  else
    tbl[next] = value
  end
end

---@param tbl table
---@param json_key string e.g. "rust-analyzer.check.overrideCommand"
---@param json_value unknown
local function override_tbl_values(tbl, json_key, json_value)
  local keys = vim.split(json_key, '%.')
  tbl_set(tbl, keys, json_value)
end

---@param json_content string
---@return table
function M.silent_decode(json_content)
  local ok, json_tbl = pcall(vim.json.decode, json_content)
  if not ok or type(json_tbl) ~= 'table' then
    return {}
  end
  return json_tbl
end

---@param tbl table
---@param json_tbl { [string]: unknown }
---@param key_predicate? fun(string): boolean
function M.override_with_json_keys(tbl, json_tbl, key_predicate)
  for json_key, value in pairs(json_tbl) do
    if not key_predicate or key_predicate(json_key) then
      override_tbl_values(tbl, json_key, value)
    end
  end
end

---@param tbl table
---@param json_tbl { [string]: unknown }
function M.override_with_rust_analyzer_json_keys(tbl, json_tbl)
  M.override_with_json_keys(tbl, json_tbl, function(key)
    return vim.startswith(key, 'rust-analyzer')
  end)
end

return M
